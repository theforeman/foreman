class CreatePuppetclasses < ActiveRecord::Migration[4.2]
  def up
    create_table :puppetclasses do |t|
      t.string :name, :limit => 255
      t.string :nameindicator, :limit => 255
      t.integer :operatingsystem_id

      t.timestamps null: true
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
