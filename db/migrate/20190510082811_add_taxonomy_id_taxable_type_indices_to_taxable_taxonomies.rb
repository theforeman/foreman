class AddTaxonomyIdTaxableTypeIndicesToTaxableTaxonomies < ActiveRecord::Migration[5.2]
  def up
    add_index :taxable_taxonomies, ["taxonomy_id", "taxable_type"]
    remove_index :taxable_taxonomies, :taxonomy_id
  end

  def down
    add_index :taxable_taxonomies, :taxonomy_id
    remove_index :taxable_taxonomies, ["taxonomy_id", "taxable_type"]
  end
end
