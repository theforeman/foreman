class CreateTaxonomies < ActiveRecord::Migration[4.2]
  def up
    create_table :taxonomies do |t|
      t.string :name, :limit => 255
      t.string :type, :limit => 255

      t.timestamps null: true
    end
  end

  def down
    drop_table :taxonomies
  end
end
