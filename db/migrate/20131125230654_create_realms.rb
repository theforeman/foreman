class CreateRealms < ActiveRecord::Migration[4.2]
  def up
    create_table :realms do |t|
      t.string      :name, :default => "", :null => false, :limit => 255
      t.string      :realm_type, :limit => 255
      t.integer     :realm_proxy_id
      t.integer     :hosts_count, :default => 0
      t.integer     :hostgroups_count, :default => 0
      t.timestamps null: true
    end

    add_index :realms, :name, :unique => true

    add_column :hosts, :otp, :string, :limit => 255 unless column_exists? :hosts, :otp
    add_column :hosts, :realm_id, :integer unless column_exists? :hosts, :realm_id
    add_column :hostgroups, :realm_id, :integer unless column_exists? :hostgroups, :realm_id

    add_foreign_key :realms, :smart_proxies, :name => "realms_realm_proxy_id_fk", :column => "realm_proxy_id"
    add_foreign_key :hosts, :realms, :name => "hosts_realms_id_fk"
    add_foreign_key :hostgroups, :realms, :name => "hostgroups_realms_id_fk"
  end

  def down
    drop_table :realms
    remove_column :hosts, :otp
    remove_column :hosts, :realm_id
    remove_column :hostgroups, :realm_id

    remove_foreign_key :hosts, :name => "hosts_realms_id_fk"
    remove_foreign_key :hostgroups, :name => "hostgroups_realms_id_fk"
  end
end
