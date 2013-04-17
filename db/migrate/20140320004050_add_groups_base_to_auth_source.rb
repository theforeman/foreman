class AddGroupsBaseToAuthSource < ActiveRecord::Migration
  def change
    add_column :auth_sources, :groups_base, :string
  end
end
