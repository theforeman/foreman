class Authorizer
  attr_accessor :user, :base_collection

  def initialize(user, collection = nil)
    @cache = Hash.new { |h, k| h[k] = {} }
    self.user = user
    self.base_collection = collection
  end

  def can?(permission, subject = nil)
    if subject.nil?
      user.permissions.where(:name => permission).present?
    else
      return true if user.admin?
      collection = @cache[subject.class.to_s][permission] ||= find_collection(subject.class, permission)
      collection.include?(subject)
    end
  end

  def find_collection(resource_class, permission = nil)
    base = user.filters.joins(:permissions).where(["#{Permission.table_name}.resource_type = ?", resource_name(resource_class)])
    all_filters = permission.nil? ? base : base.where(["#{Permission.table_name}.name = ?", permission])

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

    strings = filters.map { |f| "(#{f.search.blank? ? '1=1' : f.search})" }
    strings.join(' OR ')
  end

  private

  # sometimes we need exceptions however we don't want to just split namespaces
  def resource_name(klass)
    return 'Operatingsystem' if klass <= Operatingsystem

    case name = klass.to_s
      when 'Audited::Adapters::ActiveRecord::Audit'
        'Audit'
      when 'Host::Managed'
        'Host'
      when /\AForeman::Model::.*\Z/
        'ComputeResource'
      else
        name
      end
  end

  def base_ids
    raise ArgumentError, 'you must set base_collection to get base_ids' if @base_collection.nil?

    @base_ids ||= @base_collection.map(&:id)
  end

end
