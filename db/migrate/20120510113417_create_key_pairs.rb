class CreateKeyPairs < ActiveRecord::Migration
  def up
    create_table :key_pairs do |t|
      t.text :secret
      t.integer :compute_resource_id
      t.string :name

      t.timestamps
    end
  end

  def down
    drop_table :key_pairs
  end
end
