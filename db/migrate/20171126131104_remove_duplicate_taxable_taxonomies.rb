class RemoveDuplicateTaxableTaxonomies < ActiveRecord::Migration[4.2]
  def up
    deduped = TaxableTaxonomy.group(:taxonomy_id, :taxable_id, :taxable_type).pluck(TaxableTaxonomy.arel_table[:id].minimum)
    TaxableTaxonomy.where.not(id: deduped).delete_all
    remove_index :taxable_taxonomies, :name => 'taxable_index'
    add_index :taxable_taxonomies, [:taxable_id, :taxable_type, :taxonomy_id], :name => 'taxable_index', :unique => true
  end

  def down
    remove_index :taxable_taxonomies, :name => 'taxable_index'
    add_index :taxable_taxonomies, [:taxable_id, :taxable_type, :taxonomy_id], :name => 'taxable_index'
  end
end
