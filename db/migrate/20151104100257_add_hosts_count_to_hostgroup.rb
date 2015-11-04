class AddHostsCountToHostgroup < ActiveRecord::Migration
  def up
    add_column :hostgroups, :hosts_count, :integer, :default => 0
    Hostgroup.all.each do |hg|
      Hostgroup.reset_counters(hg.id, :hosts)
    end
  end

  def down
    remove_column :hostgroups, :hosts_count
  end
end
