class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :operatingsystem_id
      t.integer :compute_resource_id
      t.integer :architecture_id
      t.string :uuid
      t.string :username
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
