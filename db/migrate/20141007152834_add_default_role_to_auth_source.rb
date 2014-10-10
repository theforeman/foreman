class AddDefaultRoleToAuthSource < ActiveRecord::Migration
  def change
    add_column :auth_sources, :default_roles, :text , :default => [].to_yaml
  end
end
