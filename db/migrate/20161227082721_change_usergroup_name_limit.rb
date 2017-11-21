class ChangeUsergroupNameLimit < ActiveRecord::Migration[4.2]
  def change
    change_column :usergroups, :name, :string, :null => false, :limit => 255
  end
end
