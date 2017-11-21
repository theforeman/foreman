class CreateWidgets < ActiveRecord::Migration[4.2]
  def change
    create_table :widgets do |t|
      t.references :user, :index => true

      t.string  :template, :null => false, :limit => 255
      t.string  :name,     :null => false, :limit => 255
      t.text    :data
      t.integer :sizex, :default => 4
      t.integer :sizey, :default => 1
      t.integer :col, :default => 1
      t.integer :row, :default => 1
      t.boolean :hide, :default => false

      t.timestamps null: true
    end
  end
end
