class CreateKeyPairs < ActiveRecord::Migration
  def self.up
    create_table :key_pairs do |t|
      t.text :secret
      t.integer :compute_resource_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :key_pairs
  end
end
