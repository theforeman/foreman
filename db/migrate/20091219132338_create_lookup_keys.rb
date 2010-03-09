class CreateLookupKeys < ActiveRecord::Migration
  def self.up
    create_table :lookup_keys do |t|
      t.string :key
      t.timestamps
    end
    add_index :lookup_keys, :key
  end

  def self.down
    remove_index :lookup_keys, :key
    drop_table :lookup_keys
  end
end
