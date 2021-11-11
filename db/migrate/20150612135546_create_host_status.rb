class CreateHostStatus < ActiveRecord::Migration[4.2]
  def up
    create_table :host_status do |t|
      t.string :type, :limit => 255
      t.integer :status, :default => 0, :null => false, :limit => 5
      t.references :host, :null => false
      t.datetime :reported_at, :null => false
    end
    add_index :host_status, :host_id
    add_foreign_key "host_status", "hosts", :name => "host_status_hosts_host_id_fk", :column => 'host_id'
    add_column :hosts, :global_status, :integer, :default => 0, :null => false

    remove_column :hosts, :puppet_status
  end

  def down
    add_column :hosts, :puppet_status, :bigint, :null => false, :default => 0
    remove_column :hosts, :global_status
    remove_foreign_key "host_status", :name => "host_status_hosts_host_id_fk"
    remove_index :host_status, :host_id

    drop_table :host_status
  end
end
