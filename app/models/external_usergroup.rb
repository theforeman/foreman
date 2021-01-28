class ExternalUsergroup < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :usergroup, :inverse_of => :external_usergroups
  belongs_to :auth_source

  delegate :supports_refresh?, :to => :auth_source

  validates_lengths_from_database
  validates :name, :uniqueness => { :scope => :auth_source_id }
  validates :name, :auth_source, :usergroup, :presence => true
  validate :hidden_authsource_restricted
  validate :in_auth_source?, :if => proc { |eu| eu.auth_source.respond_to?(:valid_group?) }
  validate :domain_users_forbidden

  def refresh
    auth_source.refresh_usergroup_members(usergroup)
  end

  def users
    auth_source.users_in_group(name)
  rescue Net::LDAP::Error => e
    errors.add :auth_source_id, _("LDAP error - %{message}") % { :message => e.message }
    false
  end

  private

  def in_auth_source?(source = auth_source)
    errors.add :name, _("is not found in the authentication source") unless source.valid_group?(name)
  rescue Net::LDAP::Error => e
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
