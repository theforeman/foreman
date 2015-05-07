class CreateSettings < ActiveRecord::Migration
  def up
    create_table :settings do |t|
      t.string :name
      t.text :value
      t.text :description
      t.string :category
      t.string :settings_type
      t.text :default, :null => false
      t.timestamps
    end
    add_index :settings, :name, :unique => true
  end

  def down
    drop_table :settings
  end
end
