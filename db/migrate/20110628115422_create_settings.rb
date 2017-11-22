class CreateSettings < ActiveRecord::Migration[4.2]
  def up
    create_table :settings do |t|
      t.string :name, :limit => 255
      t.text :value
      t.text :description
      t.string :category, :limit => 255
      t.string :settings_type, :limit => 255
      t.text :default, :null => false
      t.timestamps null: true
    end
    add_index :settings, :name, :unique => true
  end

  def down
    drop_table :settings
  end
end
