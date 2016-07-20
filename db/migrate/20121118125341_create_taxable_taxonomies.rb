class CreateTaxableTaxonomies < ActiveRecord::Migration[4.2]
  def up
    create_table :taxable_taxonomies do |t|
      t.integer :taxonomy_id
      t.integer :taxable_id
      t.string :taxable_type, :limit => 255

      t.timestamps null: true
    end

    add_index :taxable_taxonomies, [:taxable_id, :taxable_type]
    add_index :taxable_taxonomies, [:taxable_id, :taxable_type, :taxonomy_id], :name => 'taxable_index'
    add_index :taxable_taxonomies, :taxonomy_id
  end

  def down
    drop_table :taxable_taxonomies
  end
end
