class CreateOrganizationMedia < ActiveRecord::Migration
  def self.up
    create_table :organization_media do |t|
      t.integer :organization_id
      t.integer :medium_id

      t.timestamps
    end
  end

  def self.down
    drop_table :organization_media
  end
end
