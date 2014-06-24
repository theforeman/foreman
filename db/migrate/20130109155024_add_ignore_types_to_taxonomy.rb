class AddIgnoreTypesToTaxonomy < ActiveRecord::Migration
  def self.up
    add_column :taxonomies, :ignore_types, :text
  end

  def self.down
    remove_column :taxonomies, :ignore_types
  end
end
