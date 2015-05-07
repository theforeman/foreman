class CreatePuppetclasses < ActiveRecord::Migration
  def up
    create_table :puppetclasses do |t|
      t.string :name
      t.string :nameindicator
      t.integer :operatingsystem_id

      t.timestamps
    end
    create_table :hosts_puppetclasses, :id => false do |t|
      t.references :puppetclass, :null => false
      t.references :host, :null => false
    end

    create_table :operatingsystems_puppetclasses, :id => false do |t|
      t.references :puppetclass, :null => false
      t.references :operatingsystem, :null => false
    end
  end

  def down
    drop_table :puppetclasses
    drop_table :hosts_puppetclasses
    drop_table :operatingsystems_puppetclasses
  end
end
