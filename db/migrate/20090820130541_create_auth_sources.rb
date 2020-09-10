class CreateAuthSources < ActiveRecord::Migration[4.2]
  def up
    create_table :auth_sources do |t|
      t.string  "type",              :limit => 30, :default => "",    :null => false
      t.string  "name",              :limit => 60, :default => "",    :null => false
      t.string  "host",              :limit => 60
      t.integer "port"
      t.string  "account",           :limit => 255
      t.string  "account_password",  :limit => 60
      t.string  "base_dn",           :limit => 255
      t.string  "attr_login",        :limit => 30
      t.string  "attr_firstname",    :limit => 30
      t.string  "attr_lastname",     :limit => 30
      t.string  "attr_mail",         :limit => 30
      t.boolean "onthefly_register",               :default => false, :null => false
      t.boolean "tls",                             :default => false, :null => false

      t.timestamps null: true
    end
  end

  def down
    drop_table :auth_sources
  end
end
