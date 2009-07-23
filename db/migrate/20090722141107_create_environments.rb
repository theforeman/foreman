class CreateEnvironments < ActiveRecord::Migration
  def self.up
    create_table :environments do |t|
      t.string :name, :null => false
      t.integer :hosttype_id
      t.timestamps
    end
    create_table :environments_hosttypes, :id => false do |t|
      t.references :hosttype, :null => false
      t.references :environment, :null => false
    end
 
  end

  def self.down
    drop_table :environments
  end
end
