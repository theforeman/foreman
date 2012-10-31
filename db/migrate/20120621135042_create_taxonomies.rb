class CreateTaxonomies < ActiveRecord::Migration
  def self.up
    create_table :taxonomies do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomies
  end
end
