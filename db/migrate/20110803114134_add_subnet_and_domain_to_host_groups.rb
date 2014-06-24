class AddSubnetAndDomainToHostGroups < ActiveRecord::Migration
  def self.up
    add_column :hostgroups, :subnet_id, :integer unless column_exists? :hostgroups, :subnet_id
    add_column :hostgroups, :domain_id, :integer unless column_exists? :hostgroups, :domain_id
  end

  def self.down
    remove_column :hostgroups, :subnet_id if column_exists? :hostgroups, :subnet_id
    remove_column :hostgroups, :domain_id if column_exists? :hostgroups, :domain_id
  end
end
