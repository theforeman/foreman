class HostgroupInheritanceResolver
  def self.build_cache(hostgroups, associations: [])
    records = Array(hostgroups)
    return { :resolvers => {}, :ancestors => {} } if records.empty?

    preload_associations(records, associations)

    ancestor_ids = records.flat_map(&:ancestor_ids).uniq
    ancestor_index = preload_ancestor_index(ancestor_ids, associations)

    records.each_with_object({ :resolvers => {}, :ancestors => {} }) do |hostgroup, cache|
      ancestors = hostgroup.ancestor_ids.filter_map { |ancestor_id| ancestor_index[ancestor_id] }
      cache[:ancestors][hostgroup.id] = ancestors
      cache[:resolvers][hostgroup.id] = new(hostgroup, ancestors: ancestors)
    end
  end

  def self.preload_associations(records, associations)
    return if associations.blank?

    ActiveRecord::Associations::Preloader.new(records: records, associations: associations).call
  end

  def self.preload_ancestor_index(ancestor_ids, associations)
    return {} if ancestor_ids.empty?

    scope = Hostgroup.where(:id => ancestor_ids)
    scope = scope.includes(*associations) if associations.present?
    scope.to_a.index_by(&:id)
  end
  private_class_method :preload_associations, :preload_ancestor_index

  def initialize(hostgroup, ancestors: nil)
    @hostgroup = hostgroup
    @ancestors = normalized_ancestors(ancestors)
  end

  def inherited_attribute(attribute)
    attribute = attribute.to_sym
    return @hostgroup[attribute] unless @hostgroup.ancestry.present?

    return @hostgroup[attribute] unless @hostgroup[attribute].nil?

    resolution_for(attribute)[:value]
  end

  def nested_attribute(attribute)
    return unless @hostgroup.ancestry.present?

    resolution_for(attribute.to_sym)[:value]
  end

  def source_for(attribute)
    return unless @hostgroup.ancestry.present?

    resolution_for(attribute.to_sym)[:source]
  end

  def association(association_name)
    association_name = association_name.to_sym
    field = :"#{association_name}_id"
    return @hostgroup.public_send(association_name) unless @hostgroup.ancestry.present?
    return @hostgroup.public_send(association_name) if @hostgroup[field].present?

    source_for(field)&.public_send(association_name)
  end

  def attributes_for(attributes)
    Array(attributes).index_with { |attribute| inherited_attribute(attribute) }
  end

  private

  def normalized_ancestors(ancestors)
    loaded_ancestors = ancestors
    loaded_ancestors = nil if loaded_ancestors.present? && loaded_ancestors.size != @hostgroup.ancestor_ids.size
    loaded_ancestors ||= @hostgroup.ancestors.to_a
    Hostgroup.sort_by_ancestry(loaded_ancestors)
  end

  def resolution_for(attribute)
    @resolutions ||= {}
    return @resolutions[attribute] if @resolutions.key?(attribute)

    value = nil
    source = nil

    @ancestors.each do |ancestor|
      next if ancestor[attribute].nil?

      value = ancestor[attribute]
      source = ancestor
    end

    @resolutions[attribute] = { :value => value, :source => source }
  end
end
