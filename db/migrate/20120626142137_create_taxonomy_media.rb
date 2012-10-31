class CreateTaxonomyMedia < ActiveRecord::Migration
  def self.up
    create_table :taxonomy_media do |t|
      t.integer :taxonomy_id
      t.integer :medium_id

      t.timestamps
    end
  end

  def self.down
    drop_table :taxonomy_media
  end
end
