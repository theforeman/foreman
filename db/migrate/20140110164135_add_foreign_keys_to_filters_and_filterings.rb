class AddForeignKeysToFiltersAndFilterings < ActiveRecord::Migration[4.2]
  def up
    add_foreign_key "filters", "roles", :name => "filters_roles_id_fk"
    add_foreign_key "filterings", "filters", :name => "filterings_filters_id_fk"
    add_foreign_key "filterings", "permissions", :name => "filterings_permissions_id_fk"
  end

  def down
    remove_foreign_key "filters", :name => "filters_roles_id_fk"
    remove_foreign_key "filterings", :name => "filterings_filters_id_fk"
    remove_foreign_key "filterings", :name => "filterings_permissions_id_fk"
  end
end
