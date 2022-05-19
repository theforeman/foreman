class DropUnnecessaryTimestamps < ActiveRecord::Migration[6.0]
  def change
    remove_column :taxable_taxonomies, :created_at, :datetime
    remove_column :taxable_taxonomies, :updated_at, :datetime
  end
end
