class CreateHosttypes < ActiveRecord::Migration
  def self.up
    create_table :hosttypes do |t|
      t.string :name, :limit => 32, :null => false
      t.string :nameindicator, :limit => 3

      t.timestamps
    end
    create_table :hosttypes_operatingsystems, :id => false do |t|
      t.references :hosttype, :null => false
      t.references :operatingsystem, :null => false
    end

  end

  def self.down
    drop_table :hosttypes
    drop_table :hosttypes_operatingsystems
  end
end
