class AddTaxonomySearchesToFilter < ActiveRecord::Migration[4.2]
  def up
    add_column :filters, :taxonomy_search, :text
  end

  def down
    remove_column :filters, :taxonomy_search
  end
end
