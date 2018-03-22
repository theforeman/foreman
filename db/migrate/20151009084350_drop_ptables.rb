class DropPtables < ActiveRecord::Migration[4.2]
  def up
    drop_table :ptables
  end

  def down
    create_table :ptables do |t|
      t.string :name, :limit => 64, :null => false
      t.text :layout, :null => false
      t.string :os_family, :limit => 255
      t.timestamps null: true
    end
  end
end
