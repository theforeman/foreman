class CreateTaxonomies < ActiveRecord::Migration
  def up
    create_table :taxonomies do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end

  def down
    drop_table :taxonomies
  end
end
