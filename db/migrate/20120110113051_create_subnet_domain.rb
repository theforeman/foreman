class CreateSubnetDomain < ActiveRecord::Migration
  def up
    create_table :subnet_domains do |t|
      t.references :domain
      t.references :subnet

      t.timestamps
    end

    Subnet.unscoped.find_each do |s|
      domain = Domain.unscoped.find(s.domain_id)
      domain.subnets << s
    end
    remove_column :subnets, :domain_id
  end

  def down
    add_column :subnets, :domain_id, :integer
    drop_table :subnet_domains
  end
end
