# redMine - project management software
# Copyright (C) 2006  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'net/ldap'
require 'timeout'

class AuthSourceLdap < AuthSource
  SERVER_TYPES = { :free_ipa => 'FreeIPA', :active_directory => 'Active Directory',
                   :posix    => 'POSIX'}

  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include Encryptable
  encrypts :account_password
  include Taxonomix

  validates :host, :presence => true, :length => {:maximum => 60}
  validates :attr_login, :attr_firstname, :attr_lastname, :attr_mail, :presence => true, :if => proc { |auth| auth.onthefly_register? }
  validates :attr_login, :attr_firstname, :attr_lastname, :attr_mail, :length => {:maximum => 30}, :allow_nil => true
  validates :account_password, :length => {:maximum => 60}, :allow_nil => true
  validates :port, :presence => true, :numericality => {:only_integer => true}
  validates :server_type, :presence => true, :inclusion => { :in => SERVER_TYPES.keys.map(&:to_s) }
  validate :validate_ldap_filter, :unless => proc { |auth| auth.ldap_filter.blank? }

  before_validation :strip_ldap_attributes
  before_validation :sanitize_use_netgroups
  after_initialize :set_defaults

  scoped_search :on => :name, :complete_value => :true

  default_scope lambda {
    with_taxonomy_scope do
      order("#{AuthSourceLdap.table_name}.name")
    end
  }

  DEFAULT_PORTS = {:ldap => 389, :ldaps => 636 }
  # Loads the LDAP info for a user and authenticates the user with their password
  # Returns : Array of Strings.
  #           Either the users's DN or the user's full details OR nil
  def authenticate(login = account, password = account_password)
    return if login.blank? || password.blank?

    logger.debug "LDAP auth with user #{login} against #{self}"

    conn = ldap_con(login, password)
    return unless conn.valid_user?(login)
    entry = conn.find_user(login).last
    attrs = attributes_values(entry)

    unless conn.authenticate?(login, password)
      auth_result = conn.ldap.ldap.get_operation_result
      logger.warn "Result: #{auth_result.code}"
      logger.warn "Message: #{auth_result.message}"
      logger.warn "Failed to authenticate #{login}"
      return
    end

    attrs.each { |k, v| attrs[k] = v.force_encoding('UTF-8') unless v == '' }

    logger.debug "Retrieved LDAP Attributes for #{login}: #{attrs}"

    attrs
  rescue Net::LDAP::Error, Net::LDAP::LdapError => error
    raise ::Foreman::LdapException.new(error, N_("Error while connecting to '%{name}' LDAP server at '%{url}' during authentication" % {:url => host, :name => name}))
  end

  def auth_method_name
    "LDAP"
  end

  def to_config(login = nil, password = nil)
    raise ::Foreman::Exception.new(N_('Cannot create LDAP configuration for %s without dedicated service account'), name) if login.nil? && use_user_login_for_service?
    { :host    => host,    :port => port, :encryption => encryption_config,
      :base_dn => base_dn, :group_base => groups_base, :attr_login => attr_login,
      :server_type  => server_type.to_sym, :search_filter => ldap_filter,
      :anon_queries => account.blank?, :service_user => service_user(login),
      :service_pass => use_user_login_for_service? ? password : account_password,
      :instrumentation_service => ActiveSupport::Notifications,
      :use_netgroups => use_netgroups }
  end

  def encryption_config
    return nil unless tls
    { :method => :simple_tls, :tls_options => { :verify_mode => OpenSSL::SSL::VERIFY_PEER } }
  end

  def ldap_con(login = nil, password = nil)
    if login.present?
      LdapFluff.new(to_config(login, password))
    else
      @ldap_con ||= LdapFluff.new(to_config)
    end
  rescue Net::LDAP::Error => e
    message = _("Error during LDAP connection %{name} using login %{login}: %{error}") % {name: name, login: login, error: e}
    Foreman::Logging.exception(message, e, :level => :warn)
    errors.add(:base, message)
  end

  def update_usergroups(login)
    if use_user_login_for_service?
      logger.info "Skipping user group update for user #{login} as $login is in use, group sync is unsupported"
      return
    end

    unless usergroup_sync?
      logger.info "Skipping user group update for user #{login} as usergroup_sync is disabled"
      return
    end

    logger.debug "Updating user groups for user #{login}"
    user = User.unscoped.find_by_login(login)
    external_names = ldap_con.group_list(login).map(&:downcase)
    group_name_arel = ExternalUsergroup.arel_table[:name].lower

    # User's external user groups localy
    current_external_ids = user.usergroups
                               .where(id: ExternalUsergroup.where(auth_source_id: id).select(:usergroup_id))
                               .pluck(:id)
    # User's external user groups as of auth_source
    correct_external_ids = ExternalUsergroup.where(auth_source_id: id)
                                            .where(group_name_arel.in(external_names))
                                            .pluck(:usergroup_id)

    user.usergroup_ids = (user.usergroup_ids - current_external_ids) + correct_external_ids
    # audit changes
    user.save(validate: false)
  end

  ##
  #  Sync group with external usergroup
  def refresh_usergroup_members(usergroup)
    external_groups = usergroup.external_usergroups.where(auth_source_id: id).to_a
    # Do not sync groups which are not connected with external groups
    return unless external_groups.any?
    logins = external_groups.map(&:users).select { |a| !!a }.flatten.map(&:downcase).uniq

    user_ids = User.unscoped.where(auth_source_id: id).fetch_ids_by_list(logins)
    current_user_ids = usergroup.users.where(auth_source_id: id).pluck(:id)

    usergroup.user_ids -= (current_user_ids - user_ids)
    usergroup.user_ids += (user_ids - current_user_ids)

    # audit changes - see #23377
    usergroup.save
  end

  def valid_user?(name)
    name.present? && ldap_con.valid_user?(name)
  end

  def valid_group?(name)
    return false unless name.present?
    ldap_con.valid_group?(name)
  end

  def users_in_group(name)
    ldap_con.user_list(name)
  end

  def test_connection
    result = {}
    begin
      Timeout.timeout(20) do
        ldap_con.test
      end
      result[:success] = true
      result[:message] = _("Test connection to LDAP server was successful.")
    rescue => exception
      raise ::Foreman::WrappedException.new exception, N_("Unable to connect to LDAP server")
    end
    result
  end

  private

  def strip_ldap_attributes
    [:attr_login, :attr_firstname, :attr_lastname, :attr_mail].each do |attr|
      self[attr] = self[attr].strip unless self[attr].nil?
    end
  end

  def sanitize_use_netgroups
    self.use_netgroups = false if server_type.to_s == 'active_directory'
    true
  end

  def set_defaults
    self.port ||= DEFAULT_PORTS[:ldap]
    self.attr_login ||= 'uid'
    self.attr_firstname ||= 'givenName'
    self.attr_lastname ||= 'sn'
    self.attr_mail ||= 'mail'
    self.attr_photo ||= 'jpegPhoto'
  end

  def required_ldap_attributes
    return {:dn => :dn} unless onthefly_register?
    { :firstname => attr_firstname,
      :lastname  => attr_lastname,
      :mail      => attr_mail,
      :login     => attr_login,
      :dn        => :dn,
    }
  end

  def optional_ldap_attributes
    { :avatar => attr_photo }
  end

  def attributes_values(entry)
    Hash[required_ldap_attributes.merge(optional_ldap_attributes).map do |name, value|
      next if value.blank? || (entry[value].blank? && optional_ldap_attributes.key?(name))
      if name.eql? :avatar
        [:avatar_hash, store_avatar(entry[value].first)]
      else
        value = entry[value].is_a?(Array) ? entry[value].first : entry[value]
        [name, value.to_s]
      end
    end.compact]
  end

  def avatar_path
    "#{Rails.public_path}/images/avatars"
  end

  def store_avatar(avatar)
    unless avatar.instance_of?(Net::BER::BerIdentifiedString)
      avatar = avatar.to_utf8
    end
    avatar_hash = Digest::SHA1.hexdigest(avatar)
    avatar_file = "#{avatar_path}/#{avatar_hash}.jpg"
    unless FileTest.exist? avatar_file
      FileUtils.mkdir_p(avatar_path)
      # net/ldap converts base64 data automatically to binary, in such case
      # we do not need to decode Base64 and we can just save the binary avatar.
      File.open(avatar_file, 'wb') do |f|
        if avatar.instance_of?(Net::BER::BerIdentifiedString)
          f.write(avatar)
        else
          f.write(Base64.decode64(avatar))
        end
      end
    end
    avatar_hash
  end

  def validate_ldap_filter
    Net::LDAP::Filter.construct(ldap_filter)
  # rubocop:disable Lint/ShadowedException, Lint/RedundantCopDisableDirective
  rescue Net::LDAP::Error, Net::LDAP::LdapError, Net::LDAP::FilterSyntaxInvalidError => e
    # rubocop:enable Lint/ShadowedException, Lint/RedundantCopDisableDirective
    message = _("invalid LDAP filter syntax")
    Foreman::Logging.exception(message, e)
    errors.add(:ldap_filter, message)
  end

  def use_user_login_for_service?
    # returns true if account is defined and includes "$login"
    (account.present? && account.include?("$login"))
  end

  def service_user(login)
    use_user_login_for_service? ? account.sub("$login", login) : account
  end
end
