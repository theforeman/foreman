class ExternalUsergroup < ActiveRecord::Base

  extend FriendlyId
  friendly_id :name

  belongs_to :usergroup, :inverse_of => :external_usergroups
  belongs_to :auth_source

  validates_lengths_from_database
  validates :name, :uniqueness => { :scope => :auth_source_id }
  validates :name, :auth_source, :usergroup, :presence => true
  validate :hidden_authsource_restricted
  validate :in_auth_source?, :if => Proc.new { |eu| eu.auth_source.respond_to?(:valid_group?) }

  def refresh
    return false unless auth_source.respond_to?(:users_in_group)

    current_users  = usergroup.users.map(&:login)
    all_users      = usergroup.external_usergroups.map(&:users).flatten.uniq

    # We need to make sure when we refresh a external_usergroup
    # other external_usergroup users remain in. Otherwise refreshing
    # a external user group with no users in will empty the user group.
    old_users = current_users - all_users
    new_users = users - current_users

    usergroup.remove_users(old_users)
    usergroup.add_users(new_users)
    true
  end

  def users
    auth_source.users_in_group(name)
  end

  private

  def in_auth_source?(source = auth_source)
    errors.add :name, _("is not found in the authentication source") unless source.valid_group?(name)
  rescue Net::LDAP::LdapError => e
    errors.add :auth_source_id, _("LDAP error - %{message}") % { :message => e.message }
  end

  def hidden_authsource_restricted
    if auth_source_id_changed? && auth_source.kind_of?(AuthSourceHidden)
      errors.add :auth_source, _("is not permitted")
    end
  end
end
