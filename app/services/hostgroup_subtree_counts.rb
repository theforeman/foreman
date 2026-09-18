class HostgroupSubtreeCounts
  def initialize(hostgroups = Hostgroup, target_hostgroups: nil, direct_counts: nil)
    @hostgroups = hostgroups
    @target_hostgroups = Array(target_hostgroups).compact
    @target_ids = @target_hostgroups.each_with_object({}) { |hostgroup, ids| ids[hostgroup.id] = true }
    @direct_counts = direct_counts
  end

  def totals
    direct_counts = @direct_counts || HostCounter.new(:hostgroup).hosts_count
    subtree_totals = Hash.new(0)

    hostgroup_rows.each do |hostgroup_id, ancestry|
      count = direct_counts[hostgroup_id].to_i
      next if count.zero?

      lineage_ids(ancestry, hostgroup_id).each do |ancestor_id|
        next if @target_ids.present? && !@target_ids[ancestor_id]

        subtree_totals[ancestor_id] += count
      end
    end

    subtree_totals
  end

  private

  def hostgroup_rows
    scoped_hostgroups.reorder('').pluck(:id, :ancestry)
  end

  def lineage_ids(ancestry, hostgroup_id)
    ids = ancestry.present? ? ancestry.split('/').map(&:to_i) : []
    ids << hostgroup_id
    ids
  end

  def scoped_hostgroups
    return @hostgroups if @target_hostgroups.blank?

    @hostgroups.where(subtree_condition)
  end

  def subtree_condition
    quoted_table = Hostgroup.quoted_table_name
    clauses = []

    @target_hostgroups.each do |hostgroup|
      path = hostgroup.path_ids.join('/')
      clauses << "#{quoted_table}.id = #{hostgroup.id}"
      clauses << "#{quoted_table}.ancestry = #{Hostgroup.connection.quote(path)}"
      clauses << "#{quoted_table}.ancestry LIKE #{Hostgroup.connection.quote("#{path}/%")}"
    end

    clauses.join(' OR ')
  end
end
