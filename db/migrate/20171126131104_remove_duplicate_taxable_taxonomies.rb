class RemoveDuplicateTaxableTaxonomies < ActiveRecord::Migration[4.2]
  def up
    remove_index :taxable_taxonomies, :name => 'taxable_index'
    add_index :taxable_taxonomies, [:taxable_id, :taxable_type, :taxonomy_id], :name => 'taxable_index', :unique => true
  end

  def down
    remove_index :taxable_taxonomies, :name => 'taxable_index'
    add_index :taxable_taxonomies, [:taxable_id, :taxable_type, :taxonomy_id], :name => 'taxable_index'
  end
end
