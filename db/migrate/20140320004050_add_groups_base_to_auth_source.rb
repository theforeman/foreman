class AddGroupsBaseToAuthSource < ActiveRecord::Migration[4.2]
  def change
    add_column :auth_sources, :groups_base, :string, :limit => 255
  end
end
