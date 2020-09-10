class RenameDomainHostCount < ActiveRecord::Migration[4.2]
  # prevent wierdness with rails treating hosts_count as cached counter in some cases
  def up
    rename_column :domains, :hosts_count, :total_hosts
  end

  def down
    rename_column :domains, :total_hosts, :hosts_count
  end
end
