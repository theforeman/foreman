class AddDescriptionToTaxonomies < ActiveRecord::Migration[4.2]
  def change
    add_column :taxonomies, :description, :text unless column_exists?(:taxonomies, :description)
  end
end
