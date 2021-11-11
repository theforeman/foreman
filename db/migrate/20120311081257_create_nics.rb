class CreateNics < ActiveRecord::Migration[4.2]
  def up
    create_table :nics do |t|
      t.string :mac, :limit => 255
      t.string :ip, :limit => 255
      t.string :type, :limit => 255
      t.string :name, :limit => 255
      t.references :host
      t.references :subnet
      t.references :domain
      t.text :attrs

      t.timestamps null: true
    end

    add_index :nics, [:type], :name => 'index_by_type'
    add_index :nics, [:host_id], :name => 'index_by_host'
    add_index :nics, [:type, :id], :name => 'index_by_type_and_id'

    remove_columns :hosts, :sp_mac, :sp_ip, :sp_name, :sp_subnet_id
  end

  def down
    add_column :hosts, :sp_mac, :string, :limit => 17, :default => ""
    add_column :hosts, :sp_ip, :string, :limit => 15, :default => ""
    add_column :hosts, :sp_name, :string, :limit => 255, :default => ""
    add_column :hosts, :sp_subnet_id, :integer

    drop_table :nics
  end
end
