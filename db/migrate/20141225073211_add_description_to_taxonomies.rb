class AddDescriptionToTaxonomies < ActiveRecord::Migration
  def change
    add_column :taxonomies, :description, :text unless column_exists?(:taxonomies, :description)
  end
end
