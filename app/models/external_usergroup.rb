class ExternalUsergroup < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :usergroup, :inverse_of => :external_usergroups
  belongs_to :auth_source

  validates_lengths_from_database
  validates :name, :uniqueness => { :scope => :auth_source_id }
  validates :name, :auth_source, :usergroup, :presence => true
  validate :hidden_authsource_restricted
  validate :in_auth_source?, :if => Proc.new { |eu| eu.auth_source.respond_to?(:valid_group?) }
  validate :domain_users_forbidden

  def refresh
    return false unless auth_source.respond_to?(:users_in_group)

    current_users = usergroup.users.map(&:login)
    internal_users = usergroup.users.
      where(:auth_source => AuthSourceInternal.first).map(&:login)
    my_users = users
    return false unless my_users

    all_other_users = (usergroup.external_usergroups - [self]).map(&:users)
    all_users = (all_other_users + my_users).flatten.uniq

    # We need to make sure when we refresh a external_usergroup
    # other external_usergroup users remain in. Otherwise refreshing
    # a external user group with no users in will empty the user group.
    old_users = current_users - all_users - internal_users
    new_users = my_users - current_users

    remaining_user_ids = usergroup.user_ids - User.fetch_ids_by_list(old_users)
    new_user_ids = User.fetch_ids_by_list(new_users)

    # To make changes auditable called update
    usergroup.user_ids = remaining_user_ids.concat(new_user_ids)
    usergroup.save
    true
  end

  def users
    auth_source.users_in_group(name)
  rescue Net::LDAP::Error, Net::LDAP::LdapError => e
    errors.add :auth_source_id, _("LDAP error - %{message}") % { :message => e.message }
    false
  end

  private

  def in_auth_source?(source = auth_source)
    errors.add :name, _("is not found in the authentication source") unless source.valid_group?(name)
  rescue Net::LDAP::Error, Net::LDAP::LdapError => e
    errors.add :auth_source_id, _("LDAP error - %{message}") % { :message => e.message }
  end

  def hidden_authsource_restricted
    if auth_source_id_changed? && auth_source.is_a?(AuthSourceHidden)
      errors.add :auth_source, _("is not permitted")
    end
  end

  def domain_users_forbidden
    if auth_source.server_type == 'active_directory' &&
       name.downcase == 'domain users'
      errors.add(
        :name,
        _("Domain Users is a special group in AD. Unfortunately, we cannot "\
          "obtain membership information from a LDAP search and therefore "\
          "sync it.")
      )
    end
  end
end
