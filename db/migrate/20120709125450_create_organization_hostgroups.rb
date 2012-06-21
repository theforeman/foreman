class CreateOrganizationHostgroups < ActiveRecord::Migration
  def self.up
    create_table :organization_hostgroups do |t|
      t.integer :organization_id
      t.integer :hostgroup_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_hostgroups
  end
end
