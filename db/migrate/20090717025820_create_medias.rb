class CreateMedias < ActiveRecord::Migration
  def self.up
    create_table :medias do |t|
      t.string :name,       :limit => 10, :default => "", :null => false
      t.string :path
      t.integer :operatingsystem_id
      t.timestamps
    end
  end

  def self.down
    drop_table :medias
  end
end
