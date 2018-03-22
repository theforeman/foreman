class CreateLookupValues < ActiveRecord::Migration[4.2]
  def up
    create_table :lookup_values do |t|
      t.string :priority, :limit => 255
      t.string :value, :limit => 255
      t.references :lookup_key

      t.timestamps null: true
    end
    add_index :lookup_values, :priority
  end

  def down
    remove_index :lookup_values, :priority
    drop_table :lookup_values
  end
end
