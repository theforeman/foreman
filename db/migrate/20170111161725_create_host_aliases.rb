class CreateHostAliases < ActiveRecord::Migration
  def up
    create_table :host_aliases do |t|
      t.string :name, :limit => 255
      t.integer :nic_id
      t.integer :domain_id

      t.timestamps null: false
    end
    add_index :host_aliases, :name
    add_index :host_aliases, :nic_id
  end

  def down
    drop_table :host_aliases
  end
end
