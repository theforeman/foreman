class AddIgnoreTypesToTaxonomy < ActiveRecord::Migration
  def up
    add_column :taxonomies, :ignore_types, :text
  end

  def down
    remove_column :taxonomies, :ignore_types
  end
end
