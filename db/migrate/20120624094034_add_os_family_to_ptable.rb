class AddOsFamilyToPtable < ActiveRecord::Migration[4.2]
  def up
    add_column :ptables, :os_family, :string, :limit => 255 unless column_exists? :ptables, :os_family
    remove_column :ptables, :operatingsystem_id if column_exists? :ptables, :operatingsystem_id
  end

  def down
    remove_column :ptables, :os_family                 if     column_exists? :ptables, :os_family
    add_column :ptables, :operatingsystem_id, :integer unless column_exists? :ptables, :operatingsystem_id
  end
end
