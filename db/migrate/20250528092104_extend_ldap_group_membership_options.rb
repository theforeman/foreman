class ExtendLdapGroupMembershipOptions < ActiveRecord::Migration[7.0]
  def up
    add_column :auth_sources, :ldap_group_membership, :string
    AuthSourceLdap.where.not(server_type: 'active_directory').update_all(ldap_group_membership: 'posix')
    AuthSourceLdap.where(use_netgroups: true).update_all(ldap_group_membership: 'nis_netgroups')
    remove_column :auth_sources, :use_netgroups
  end

  def down
    add_column :auth_sources, :use_netgroups, :boolean, :default => false
    AuthSourceLdap.where(ldap_group_membership: 'nis_netgroups').update_all(use_netgroups: true)
    remove_column :auth_sources, :ldap_group_membership
  end
end
