class AddSubnetAndDomainToHostGroups < ActiveRecord::Migration
  def self.up
    add_column :hostgroups, :subnet_id, :integer
    add_column :hostgroups, :domain_id, :integer
  end

  def self.down
    remove_column :hostgroups, :subnet_id
    remove_column :hostgroups, :domain_id
  end
end
