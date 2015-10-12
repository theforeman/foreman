class DropPtables < ActiveRecord::Migration
  def up
    drop_table :ptables
  end

  def down
    create_table :ptables do |t|
      t.string :name, :limit => 64, :null => false
      t.text :layout, :null => false
      t.string :os_family
      t.timestamps
    end
  end
end
