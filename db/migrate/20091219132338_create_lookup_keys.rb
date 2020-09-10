class CreateLookupKeys < ActiveRecord::Migration[4.2]
  def up
    create_table :lookup_keys do |t|
      t.string :key, :limit => 255
      t.timestamps null: true
    end
    add_index :lookup_keys, :key
  end

  def down
    remove_index :lookup_keys, :key
    drop_table :lookup_keys
  end
end
