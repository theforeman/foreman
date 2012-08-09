class AddTypeColumnToTaxonomies < ActiveRecord::Migration
  def self.up
    add_column :taxonomies, :type, :string
  end

  def self.down
    remove_column :taxonomies, :type
  end
end
