class CreateEnvironments < ActiveRecord::Migration
  def self.up
    create_table :environments do |t|
      t.string :name, :null => false
      t.timestamps
    end
    create_table :environments_puppetclasses, :id => false do |t|
      t.references :puppetclass, :null => false
      t.references :environment, :null => false
    end
 
  end

  def self.down
    drop_table :environments
    drop_table :environments_puppetclasses
  end
end
