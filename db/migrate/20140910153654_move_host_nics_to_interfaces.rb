class MoveHostNicsToInterfaces < ActiveRecord::Migration[4.2]
  def up
    add_column :nics, :primary, :boolean, :default => false
    add_column :nics, :provision, :boolean, :default => false

    remove_column :hosts, :ip
    remove_column :hosts, :mac
    remove_column :hosts, :primary_interface
    remove_foreign_key 'hosts', :name => 'hosts_subnet_id_fk'
    remove_column :hosts, :subnet_id
    remove_foreign_key 'hosts', :name => 'hosts_domain_id_fk'
    remove_column :hosts, :domain_id
  end

  def down
    add_column :hosts, :ip, :string, :limit => 255
    add_column :hosts, :mac, :string, :default => '', :limit => 255
    add_column :hosts, :primary_interface, :string, :limit => 255
    add_column :hosts, :subnet_id, :integer
    add_foreign_key 'hosts', 'subnets', :name => 'hosts_subnet_id_fk'
    add_column :hosts, :domain_id, :integer
    add_foreign_key 'hosts', 'subnets', :name => 'hosts_domain_id_fk'

    remove_column :nics, :primary
    remove_column :nics, :provision
  end
end
