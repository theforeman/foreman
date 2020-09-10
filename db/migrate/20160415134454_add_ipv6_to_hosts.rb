class AddIpv6ToHosts < ActiveRecord::Migration[4.2]
  def self.up
    change_column :nics, :ip, :string, :limit => 15
    add_index :nics, :ip
    add_column :nics, :ip6, :string, :limit => 45
    add_index :nics, :ip6
    add_column :hostgroups, :subnet6_id, :integer
    add_column :nics, :subnet6_id, :integer
  end

  def self.down
    change_column :nics, :ip, :string
    remove_index :nics, :ip
    remove_column :nics, :ip6
    remove_column :hostgroups, :subnet6_id
    remove_column :nics, :subnet6_id
  end
end
