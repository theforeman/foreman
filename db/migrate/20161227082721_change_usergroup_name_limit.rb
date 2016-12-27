class ChangeUsergroupNameLimit < ActiveRecord::Migration
  def change
    change_column :usergroups, :name, :string, :null => false, :limit => 255
  end
end
