class RemoveLimitLdapFilter < ActiveRecord::Migration[5.1]
  def up
    change_column 'auth_sources', :ldap_filter, :text, :limit => nil
  end

  def down
    change_column 'auth_sources', :ldap_filter, :string, :limit => 255
  end
end
