class AddLdapFilterToAuthSources < ActiveRecord::Migration
  def change
    add_column :auth_sources, :ldap_filter, :string, :limit => 255, :null => true
  end
end
