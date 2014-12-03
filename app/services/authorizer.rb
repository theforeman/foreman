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

    base = user.filters.joins(:permissions).where(["#{Permission.table_name}.resource_type = ?", resource_name(resource_class)])
    all_filters = permission.nil? ? base : base.where(["#{Permission.table_name}.name = ?", permission])

    organization_ids = allowed_organizations(resource_class)
    location_ids     = allowed_locations(resource_class)

    organizations, locations, values = taxonomy_conditions(organization_ids, location_ids)
    all_filters = all_filters.joins(taxonomy_join).where(["#{TaxableTaxonomy.table_name}.id IS NULL " +
                                                              "OR (#{organizations}) " +
                                                              "OR (#{locations})",
                                                          *values]).uniq

    all_filters = all_filters.all # load all records, so #empty? does not call extra COUNT(*) query
    return resource_class.where('1=0') if all_filters.empty?

    unless @base_collection.nil?
      if @base_collection.empty?
        return resource_class.where('1=0')
      else
        resource_class = resource_class.where(:id => base_ids)
      end
    end

    return resource_class.scoped if all_filters.any?(&:unlimited?)

    search_string = build_scoped_search_condition(all_filters.select(&:limited?))
    resource_class.search_for(search_string)
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
      if taxonomy_ids.empty? && !User.current.try(:admin?)
        taxonomy_ids = User.current.try("#{type}_ids")
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
