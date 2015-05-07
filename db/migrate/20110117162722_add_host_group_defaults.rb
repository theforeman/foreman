class AddHostGroupDefaults < ActiveRecord::Migration
  def up
    add_column :hostgroups, :environment_id, :integer
    add_column :hostgroups, :operatingsystem_id, :integer
    add_column :hostgroups, :architecture_id, :integer
    add_column :hostgroups, :medium_id, :integer
    add_column :hostgroups, :ptable_id, :integer
    add_column :hostgroups, :root_pass, :string
    add_column :hostgroups, :puppetmaster, :string
  end

  def down
    remove_column :hostgroups, :environment_id
    remove_column :hostgroups, :operatingsystem_id
    remove_column :hostgroups, :architecture_id
    remove_column :hostgroups, :medium_id
    remove_column :hostgroups, :ptable_id
    remove_column :hostgroups, :root_pass
    remove_column :hostgroups, :puppetmaster
  end
end
