class CreateMedia < ActiveRecord::Migration
  def up
    create_table :media do |t|
      t.string :name, :limit => 50, :default => "", :null => false
      t.string :path, :limit => 100, :default => "", :null => false
      t.references :operatingsystem
      t.timestamps
    end
  end

  def down
    drop_table :media
  end
end
