class CreateEnvironments < ActiveRecord::Migration[4.2]
  def up
    create_table :environments do |t|
      t.string :name, :null => false, :limit => 255
      t.timestamps null: true
    end
    create_table :environments_puppetclasses, :id => false do |t|
      t.references :puppetclass, :null => false
      t.references :environment, :null => false
    end
  end

  def down
    drop_table :environments
    drop_table :environments_puppetclasses
  end
end
