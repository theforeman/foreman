class Authorizer
  attr_accessor :user, :base_collection, :organization_ids, :location_ids

  def initialize(user, options = {})
    @cache = HashWithIndifferentAccess.new { |h, k| h[k] = HashWithIndifferentAccess.new }
    self.user = user
    self.base_collection = options.delete(:collection)
  end

  def can?(permission, subject = nil)
    if subject.nil?
      user.permissions.where(:name => permission).present?
    else
      return true if user.admin?
      collection = @cache[subject.class.to_s][permission] ||= find_collection(subject.class, :permission => permission)
      collection.include?(subject)
    end
  end

  def find_collection(resource_class, options = {})
    permission = options.delete :permission
    Foreman::Logging.logger('permissions').debug "checking permission #{permission}"

    # retrieve all filters relevant to this permission for the user
    base = user.filters.joins(:permissions).where(["#{Permission.table_name}.resource_type = ?", resource_name(resource_class)])
    all_filters = permission.nil? ? base : base.where(["#{Permission.table_name}.name = ?", permission])

    if Taxonomy.enabled_taxonomies.any?
      organization_ids = allowed_organizations(resource_class)
      Foreman::Logging.logger('permissions').debug "organization_ids: #{organization_ids.inspect}"
      location_ids     = allowed_locations(resource_class)
      Foreman::Logging.logger('permissions').debug "location_ids: #{location_ids.inspect}"

      organizations, locations, values = taxonomy_conditions(organization_ids, location_ids)
      all_filters = all_filters.joins(taxonomy_join).where(["#{TaxableTaxonomy.table_name}.id IS NULL " +
                                                                "OR (#{organizations}) " +
                                                                "OR (#{locations})",
                                                            *values]).uniq
    end

    all_filters = all_filters.to_a # load all records, so #empty? does not call extra COUNT(*) query
    Foreman::Logging.logger('permissions').debug do
      all_filters.map do |f|
        "filter with role_id: #{f.role_id} limited: #{f.limited?} search: #{f.search} taxonomy_search: #{f.taxonomy_search}"
      end.join("\n")
    end

    # retrieve hash of scoping data parsed from filters (by scoped_search), e.g. where clauses, joins
    scope_components = build_filtered_scope_components(resource_class, all_filters, options)
    if options[:joined_on]
      # build scope for the "joined_on" object filtered by the associated "resource_class"
      assoc_name = options[:association_name]
      assoc_name ||= options[:joined_on].reflect_on_all_associations.find { |a| a.klass.base_class == resource_class.base_class }.name

      scope = options[:joined_on].joins(assoc_name => scope_components[:includes]).readonly(false)

      # allow user to add their own further clauses
      scope_components[:where] << options[:where] if options[:where].present?

      # apply every where clause to the scope consecutively
      scope_components[:where].inject(scope) do |scope_build,where|
        where.is_a?(Hash) ? scope_build.where(resource_class.table_name => where) : scope_build.where(where)
      end
    else
      # build regular filtered scope for "resource_class"
      scope = resource_class.includes(scope_components[:includes]).joins(scope_components[:joins]).readonly(false)
      scope_components[:where].inject(scope) { |scope_build,where| scope_build.where(where) }
    end
  end

  def build_filtered_scope_components(resource_class, all_filters, options)
    result = { where: [], includes: [], joins: [] }

    if all_filters.empty? || (!@base_collection.nil? && @base_collection.empty?)
      Foreman::Logging.logger('permissions').debug 'no filters found for given permission' if all_filters.empty?
      Foreman::Logging.logger('permissions').debug 'base collection of objects is empty' if !@base_collection.nil? && @base_collection.empty?
      result[:where] << (user.admin? ? '1=1' : '1=0')
      return result
    end

    result[:where] << { id: base_ids } if @base_collection.present?
    return result if all_filters.any?(&:unlimited?)
    # return resource_class.all if all_filters.any?(&:unlimited?)

    search_string = build_scoped_search_condition(all_filters.select(&:limited?))
    find_options = ScopedSearch::QueryBuilder.build_query(resource_class.scoped_search_definition, search_string, options)
    result[:where] << find_options[:conditions]
    result[:includes].push(*find_options[:include])
    result[:joins].push(*find_options[:joins])
    result
  end

  def build_scoped_search_condition(filters)
    raise ArgumentError if filters.blank?

    strings = filters.map { |f| "(#{f.search_condition.blank? ? '1=1' : f.search_condition})" }
    strings.join(' OR ')
  end

  private

  def allowed_organizations(resource_class)
    allowed_taxonomies(resource_class, 'organization')
  end

  def allowed_locations(resource_class)
    allowed_taxonomies(resource_class, 'location')
  end

  # return array of taxonomies that were used by default scope
  # if model does not support taxonomies, we return empty array indicating
  #   we should not filter on taxonomies
  # otherwise we fetch it from model, if it's empty
  #   for admin user we return empty array which means don't limit
  #   for normal user we allow user taxonomies only
  def allowed_taxonomies(resource_class, type)
    taxonomy_ids = []
    if resource_class.respond_to?("used_#{type}_ids")
      taxonomy_ids = resource_class.send("used_#{type}_ids")
      if taxonomy_ids.empty? && !user.try(:admin?)
        taxonomy_ids = user.try("#{type}_ids")
      end
    end
    taxonomy_ids
  end

  def taxonomy_join
    "LEFT JOIN #{TaxableTaxonomy.table_name} ON " +
        "(#{Filter.table_name}.id = #{TaxableTaxonomy.table_name}.taxable_id AND taxable_type = 'Filter') " +
        "LEFT JOIN #{Taxonomy.table_name} ON " +
        "(#{Taxonomy.table_name}.id = #{TaxableTaxonomy.table_name}.taxonomy_id)"
  end

  def taxonomy_conditions(organization_ids, location_ids)
    values = []

    organizations = "#{Taxonomy.table_name}.type = ?"
    values.push 'Organization'
    unless organization_ids.empty?
      organizations += " AND #{Taxonomy.table_name}.id IN (?)"
      values.push organization_ids
    end

    locations = "#{Taxonomy.table_name}.type = ?"
    values.push 'Location'
    unless location_ids.empty?
      locations += " AND #{Taxonomy.table_name}.id IN (?)"
      values.push location_ids
    end

    [organizations, locations, values]
  end

  # sometimes we need exceptions however we don't want to just split namespaces
  def resource_name(klass)
    return 'Operatingsystem' if klass <= Operatingsystem
    return 'ComputeResource' if klass <= ComputeResource

    case name = klass.to_s
      when 'Audited::Adapters::ActiveRecord::Audit'
        'Audit'
      when /\AHost::.*\Z/
        'Host'
      else
        name
      end
  end

  def base_ids
    raise ArgumentError, 'you must set base_collection to get base_ids' if @base_collection.nil?

    @base_ids ||= @base_collection.all? { |i| i.is_a?(Fixnum) } ? @base_collection : @base_collection.map(&:id)
  end
end
