class ChangeColumnLengths < ActiveRecord::Migration[4.2]
  def up
    change_column :media, :name, :string, :null => false, :default => '', :limit => 255
    change_column :media, :media_path, :string, :limit => 255
    change_column :media, :config_path, :string, :limit => 255
    change_column :media, :image_path, :string, :limit => 255
    change_column :architectures, :name, :string, :default => "x86_64", :null => false, :limit => 255
    change_column :auth_sources, :type, :string, :null => false, :default => '', :limit => 255
    change_column :auth_sources, :name, :string, :null => false, :default => '', :limit => 255
    change_column :auth_sources, :host, :string, :limit => 255
    change_column :auth_sources, :account_password, :string, :limit => 255
    change_column :auth_sources, :attr_login, :string, :limit => 255
    change_column :auth_sources, :attr_firstname, :string, :limit => 255
    change_column :auth_sources, :attr_lastname, :string, :limit => 255
    change_column :auth_sources, :attr_mail, :string, :limit => 255
    change_column :domains, :fullname, :string, :limit => 255
    change_column :features, :name, :string, :limit => 255
    change_column :hosts, :mac, :string, :default => '', :limit => 255
    change_column :hosts, :root_pass, :string, :limit => 255
    change_column :hosts, :serial, :string, :limit => 255
    change_column :models, :name, :string, :null => false, :limit => 255
    change_column :models, :vendor_class, :string, :limit => 255
    change_column :models, :hardware_model, :string, :limit => 255
    change_column :operatingsystems, :name, :string, :limit => 255
    change_column :operatingsystems, :release_name, :string, :limit => 255
    change_column :operatingsystems, :type, :string, :limit => 255
    change_column :ptables, :name, :string, :null => false, :limit => 255
    change_column :roles, :name, :string, :limit => 255
  end

  def down
    change_column :media, :name, :string, :limit => 50, :null => false, :default => ''
    change_column :media, :media_path, :string, :limit => 128
    change_column :media, :config_path, :string, :limit => 128
    change_column :media, :image_path, :string, :limit => 128
    change_column :architectures, :name, :string, :limit => 10, :default => "x86_64", :null => false
    change_column :auth_sources, :type, :string, :limit => 30, :null => false, :default => ''
    change_column :auth_sources, :name, :string, :limit => 60, :null => false, :default => ''
    change_column :auth_sources, :host, :string, :limit => 60
    change_column :auth_sources, :account_password, :string, :limit => 60
    change_column :auth_sources, :attr_login, :string, :limit => 30
    change_column :auth_sources, :attr_firstname, :string, :limit => 30
    change_column :auth_sources, :attr_lastname, :string, :limit => 30
    change_column :auth_sources, :attr_mail, :string, :limit => 30
    change_column :domains, :fullname, :string, :limit => 254
    change_column :features, :name, :string, :limit => 16
    change_column :hosts, :mac, :string, :limit => 17, :default => ''
    change_column :hosts, :root_pass, :string, :limit => 64
    change_column :hosts, :serial, :string, :limit => 12
    change_column :models, :name, :string, :limit => 64, :null => false
    change_column :models, :vendor_class, :string, :limit => 32
    change_column :models, :hardware_model, :string, :limit => 16
    change_column :operatingsystems, :name, :string, :limit => 64
    change_column :operatingsystems, :release_name, :string, :limit => 64
    change_column :operatingsystems, :type, :string, :limit => 16
    change_column :ptables, :name, :string, :limit => 64, :null => false
    change_column :roles, :name, :string, :limit => 30
  end
end
