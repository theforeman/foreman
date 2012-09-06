class AddLocationAndTenantToHost < ActiveRecord::Migration
  def self.up
    add_column :hosts, :tenant_ids, :integer
    add_column :hosts, :location_ids, :integer
  end

  def self.down
    remove_column :hosts, :tenant_ids
    remove_column :hosts, :location_ids
  end
end
