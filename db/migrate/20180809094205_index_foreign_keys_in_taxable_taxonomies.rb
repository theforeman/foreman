class IndexForeignKeysInTaxableTaxonomies < ActiveRecord::Migration[5.1]
  def change
    add_index :taxable_taxonomies, :taxable_id
  end
end
