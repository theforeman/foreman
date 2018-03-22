class AddLdapFilterToAuthSources < ActiveRecord::Migration[4.2]
  def change
    add_column :auth_sources, :ldap_filter, :string, :limit => 255, :null => true
  end
end
