class Authorizer
  attr_accessor :user

  def initialize(user)
    self.user = user
  end

  def can?(permission, subject = nil)
    if subject.nil?
      user.permissions.where(:name => permission).present?
    else
      find_collection(subject.class, permission).include?(subject)
    end
  end

  def find_collection(resource_class, permission = nil)
    base = user.filters.joins(:permissions).where(["#{Permission.table_name}.resource_type = ?", resource_class.to_s])
    all_filters = permission.nil? ? base : base.where(["#{Permission.table_name}.name = ?", permission])

    return resource_class.where('1=0') if all_filters.empty?
    return resource_class.scoped if all_filters.any?(&:unlimited?)

    search_string = build_scoped_search_condition(all_filters.select(&:limited?))
    resource_class.search_for(search_string)
  end

  def build_scoped_search_condition(filters)
    raise ArgumentError if filters.blank?

    strings = filters.map { |f| "(#{f.search.blank? ? '1=1' : f.search})" }
    strings.join(' OR ')
  end

end
