class AddMyBooleansToUser < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :domains_andor,    :string, :limit => 3, :default => "or"
    add_column :users, :hostgroups_andor, :string, :limit => 3, :default => "or"
    add_column :users, :facts_andor,      :string, :limit => 3, :default => "or"
  end

  def down
    remove_column :users, :facts_andor
    remove_column :users, :hostgroups_andor
    remove_column :users, :domains_andor
  end
end
