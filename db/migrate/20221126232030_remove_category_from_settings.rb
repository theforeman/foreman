class RemoveCategoryFromSettings < ActiveRecord::Migration[6.1]
  def change
    remove_index :settings, :category
    remove_column :settings, :category, :string
  end
end
