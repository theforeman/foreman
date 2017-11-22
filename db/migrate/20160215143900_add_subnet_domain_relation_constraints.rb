class AddSubnetDomainRelationConstraints < ActiveRecord::Migration[4.2]
  def up
    change_column :subnet_domains, :subnet_id, :integer, :null => false
    change_column :subnet_domains, :domain_id, :integer, :null => false
    add_index(:subnet_domains, [:subnet_id, :domain_id], :unique => true)
  end

  def down
    remove_index(:subnet_domains, [:subnet_id, :domain_id])
    change_column :subnet_domains, :subnet_id, :integer, :null => true
    change_column :subnet_domains, :domain_id, :integer, :null => true
  end
end
