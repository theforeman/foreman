class CleanupUsersProperties < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :domains_andor           if column_exists? :users, :domains_andor
    remove_column :users, :hostgroups_andor        if column_exists? :users, :hostgroups_andor
    remove_column :users, :facts_andor             if column_exists? :users, :facts_andor
    remove_column :users, :compute_resources_andor if column_exists? :users, :compute_resources_andor
    remove_column :users, :organizations_andor     if column_exists? :users, :organizations_andor
    remove_column :users, :locations_andor         if column_exists? :users, :locations_andor
    remove_column :users, :filter_on_owner         if column_exists? :users, :filter_on_owner
  end

  def down
    add_column :users, :domains_andor           unless column_exists? :users, :domains_andor
    add_column :users, :hostgroups_andor        unless column_exists? :users, :hostgroups_andor
    add_column :users, :facts_andor             unless column_exists? :users, :facts_andor
    add_column :users, :compute_resources_andor unless column_exists? :users, :compute_resources_andor
    add_column :users, :organizations_andor     unless column_exists? :users, :organizations_andor
    add_column :users, :locations_andor         unless column_exists? :users, :locations_andor
    add_column :users, :filter_on_owner         unless column_exists? :users, :filter_on_owner
  end
end
