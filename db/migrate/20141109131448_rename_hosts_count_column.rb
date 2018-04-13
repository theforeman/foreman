class RenameHostsCountColumn < ActiveRecord::Migration[4.2]
  # prevent wierdness with rails treating hosts_count as cached counter in some cases
  def up
    rename_column :puppetclasses, :hosts_count, :total_hosts
  end

  def down
    rename_column :puppetclasses, :total_hosts, :hosts_count
  end
end
