class CreateHostgroups < ActiveRecord::Migration
  def up
    create_table :hostgroups do |t|
      t.string :name

      t.timestamps
    end

    create_table :hostgroups_puppetclasses, :id => false do |t|
      t.references :hostgroup, :null => false
      t.references :puppetclass, :null => false
    end

    add_column :hosts, :hostgroup_id, :integer
    add_column :parameters, :hostgroup_id, :integer
  end

  def down
    drop_table :hostgroups
    drop_table :hostgroups_puppetclasses
    remove_column :hosts, :hostgroup_id
    remove_column :parameters, :hostgroup_id
  end
end
