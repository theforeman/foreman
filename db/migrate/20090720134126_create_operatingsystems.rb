class CreateOperatingsystems < ActiveRecord::Migration
  def self.up
    create_table :operatingsystems do |t|
      t.string   :major, :limit => 5,  :default => "", :null => false
      t.string   :name, :limit => 64
      t.string   :minor, :limit => 16
      t.string   :nameindicator, :limit => 3

      t.timestamps
    end
  end

  def self.down
    drop_table :operatingsystems
  end
end
