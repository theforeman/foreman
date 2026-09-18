class HostgroupReadContext
  def self.load(hostgroups, include_parameters: false, include_counts: false, include_inheritance: true, count_scope: Hostgroup)
    records = Array(hostgroups).compact
    new(
      records,
      include_parameters: include_parameters,
      include_counts: include_counts,
      include_inheritance: include_inheritance,
      count_scope: count_scope
    ).tap(&:load)
  end

  def initialize(hostgroups, include_parameters:, include_counts:, include_inheritance:, count_scope:)
    @hostgroups = hostgroups
    @include_parameters = include_parameters
    @include_counts = include_counts
    @include_inheritance = include_inheritance
    @count_scope = count_scope
    @resolver_map = {}
    @ancestor_map = {}
    @direct_counts = {}
    @subtree_counts = {}
  end

  def load
    return self if @hostgroups.empty?

    if @include_inheritance
      inheritance_cache = HostgroupInheritanceResolver.build_cache(@hostgroups, associations: preload_associations)
      @resolver_map = inheritance_cache[:resolvers]
      @ancestor_map = inheritance_cache[:ancestors]
    end
    load_counts if @include_counts
    attach!
    self
  end

  def resolver_for(hostgroup)
    @resolver_map[hostgroup.id] ||= HostgroupInheritanceResolver.new(hostgroup, ancestors: ancestors_for(hostgroup))
  end

  def ancestors_for(hostgroup)
    @ancestor_map[hostgroup.id] ||= Hostgroup.sort_by_ancestry(hostgroup.ancestors.to_a)
  end

  def parent_for(hostgroup)
    ancestors_for(hostgroup).last
  end

  def direct_host_count_for(hostgroup)
    @direct_counts[hostgroup.id].to_i
  end

  def subtree_host_count_for(hostgroup)
    @subtree_counts[hostgroup.id].to_i
  end

  private

  def preload_associations
    associations = Hostgroup::API_PRELOAD_ASSOCIATIONS.dup
    associations << :group_parameters if @include_parameters
    associations
  end

  def load_counts
    @direct_counts = HostCounter.new(:hostgroup).hosts_count
    @subtree_counts = HostgroupSubtreeCounts.new(
      @count_scope,
      target_hostgroups: @hostgroups,
      direct_counts: @direct_counts
    ).totals
  end

  def attach!
    @hostgroups.each { |hostgroup| hostgroup.hostgroup_read_context = self }
  end
end
