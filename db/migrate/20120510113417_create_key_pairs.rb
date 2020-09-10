class CreateKeyPairs < ActiveRecord::Migration[4.2]
  def up
    create_table :key_pairs do |t|
      t.text :secret
      t.integer :compute_resource_id
      t.string :name, :limit => 255

      t.timestamps null: true
    end
  end

  def down
    drop_table :key_pairs
  end
end
