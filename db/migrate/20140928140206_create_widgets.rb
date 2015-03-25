class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.references :user, :index => true

      t.string  :template, :null => false
      t.string  :name,     :null => false
      t.text    :data
      t.integer :sizex, :default => 4
      t.integer :sizey, :default => 1
      t.integer :col, :default => 1
      t.integer :row, :default => 1
      t.boolean :hide, :default => false

      t.timestamps
    end
  end
end
