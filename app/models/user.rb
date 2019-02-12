require 'digest/sha1'

class User < ApplicationRecord
  audited :except => [:last_login_on, :password_hash, :password_salt, :password_confirmation],
          :associations => :roles
  include Authorizable
  extend FriendlyId
  friendly_id :login
  include Foreman::ThreadSession::UserModel
  include Taxonomix
  include DirtyAssociations
  include UserTime
  include UserUsergroupCommon
  include Exportable
  include TopbarCacheExpiry
  include JwtAuth

  ANONYMOUS_ADMIN = 'foreman_admin'
  ANONYMOUS_API_ADMIN = 'foreman_api_admin'
  ANONYMOUS_CONSOLE_ADMIN = 'foreman_console_admin'

  validates_lengths_from_database :except => [:firstname, :lastname, :format, :mail, :login]
  attr_accessor :password_confirmation, :current_password
  attribute :password

  after_save :ensure_default_role
  before_destroy EnsureNotUsedBy.new([:direct_hosts, :hosts]), :ensure_hidden_users_are_not_deleted, :ensure_last_admin_is_not_deleted

  belongs_to :auth_source
  belongs_to :default_organization, :class_name => 'Organization'
  belongs_to :default_location,     :class_name => 'Location'

  has_many :auditable_changes, :class_name => '::Audit', :as => :user
  has_many :direct_hosts,      :class_name => 'Host',    :as => :owner
  has_many :usergroup_member,  :dependent => :destroy,   :as => :member
  has_many :user_roles,        :dependent => :destroy, :as => :owner
  has_many :cached_user_roles, :dependent => :destroy
  has_many :cached_usergroup_members
  has_many :cached_usergroups, :through => :cached_usergroup_members, :source => :usergroup
  has_many :cached_roles,      -> { distinct }, :through => :cached_user_roles, :source => :role
  has_many :usergroups,        :through => :usergroup_member, :dependent => :destroy
  has_many :roles,             :through => :user_roles,       :dependent => :destroy
  has_many :filters,           :through => :cached_roles
  has_many :permissions,       :through => :filters
  has_many :widgets, :dependent => :destroy
  has_many :ssh_keys, :dependent => :destroy
  has_many :personal_access_tokens, :dependent => :destroy
  has_many :table_preferences, :dependent => :destroy, :inverse_of => :user
  has_many :user_mail_notifications, :dependent => :destroy, :inverse_of => :user
  has_many :mail_notifications, :through => :user_mail_notifications
  has_many :notification_recipients, :dependent => :delete_all

  accepts_nested_attributes_for :user_mail_notifications, :allow_destroy => true, :reject_if => :reject_empty_intervals

  attr_name :login

  scope :except_admin, lambda {
    eager_load(:cached_usergroups).
    where(["(#{self.table_name}.admin = ? OR #{self.table_name}.admin IS NULL) AND " +
           "(#{Usergroup.table_name}.admin = ? OR #{Usergroup.table_name}.admin IS NULL)",
           false, false])
  }
  scope :only_admin, lambda {
    eager_load(:cached_usergroups).
    where(["#{self.table_name}.admin = ? OR #{Usergroup.table_name}.admin = ?", true, true])
  }
  scope :except_hidden, lambda {
    if (hidden = AuthSourceHidden.pluck('auth_sources.id')).present?
      where(self.arel_table[:auth_source_id].not_in(hidden))
    else
      where(nil)
    end
  }
  scope :visible,         -> { except_hidden }
  scope :completer_scope, ->(opts) { visible }

  validates :mail, :email => true, :allow_blank => true
  validates :mail, :presence => true, :on => :update,
                   :if => Proc.new { |u| !AuthSourceHidden.where(:id => u.auth_source_id).any? && (u.mail_was.present? || (User.current == u && !User.current.hidden?)) }

  validates :locale, :format => { :with => /\A\w{2}([_-]\w{2})?\Z/ }, :allow_blank => true, :if => Proc.new { |user| user.respond_to?(:locale) }
  before_validation :normalize_locale

  def self.title_name
    "login".freeze
  end

  def self.name_format
    /\A[[:alnum:]\s'_\-\.()<>;=,]*\z/
  end

  validates :login, :presence => true, :uniqueness => {:case_sensitive => false, :message => N_("already exists")},
                    :format => {:with => /\A[[:alnum:]_\-@\.\\$#+]*\Z/}, :length => {:maximum => 100}
  validates :auth_source_id, :presence => true
  validates :password_hash, :presence => true, :if => Proc.new {|user| user.manage_password?}
  validates :password, :confirmation => true, :if => Proc.new {|user| user.manage_password?},
                       :unless => Proc.new {|user| user.password.empty?}
  validates :firstname, :lastname, :format => {:with => name_format}, :length => {:maximum => 50}, :allow_nil => true
  validate :name_used_in_a_usergroup, :ensure_hidden_users_are_not_renamed, :ensure_hidden_users_remain_admin,
           :ensure_privileges_not_escalated, :default_organization_inclusion, :default_location_inclusion,
           :ensure_last_admin_remains_admin, :hidden_authsource_restricted, :ensure_admin_password_changed_by_admin,
           :check_permissions_for_changing_login
  before_validation :verify_current_password, :if => Proc.new {|user| user == User.current},
                    :unless => Proc.new {|user| user.password.empty?}
  before_validation :prepare_password, :normalize_mail
  before_save       :set_lower_login
  before_save       :normalize_timezone

  after_create :welcome_mail
  after_create :set_default_widgets

  scoped_search :on => :login, :complete_value => :true
  scoped_search :on => :firstname, :complete_value => :true
  scoped_search :on => :lastname, :complete_value => :true
  scoped_search :on => :mail, :complete_value => :true
  scoped_search :on => :description, :complete_value => false
  scoped_search :on => :admin, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_admin
  scoped_search :on => :last_login_on, :complete_value => :true, :only_explicit => true
  scoped_search :relation => :roles, :on => :name, :rename => :role, :complete_value => true
  scoped_search :relation => :roles, :on => :id, :rename => :role_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :relation => :cached_usergroups, :on => :name, :rename => :usergroup, :complete_value => true

  default_scope lambda {
    with_taxonomy_scope do
      order('firstname')
    end
  }

  dirty_has_many_associations :roles

  attr_exportable :firstname, :lastname, :mail, :description, :fullname, :name => ->(user) { user.login }, :ssh_authorized_keys => ->(user) { user.ssh_keys.map(&:to_export_hash) }

  def as_json(options = {})
    super.tap { |h| h.key?('user') ? h['user']['name'] = name : h['name'] = name }
  end

  class Jail < ::Safemode::Jail
    allow :login, :ssh_keys, :ssh_authorized_keys, :description, :firstname, :lastname, :mail
  end

  # we need to allow self-editing and self-updating
  def check_permissions_after_save
    if User.current.try(:id) == self.id
      true
    else
      super
    end
  end

  def can?(permission, subject = nil)
    if self.admin?
      true
    else
      @authorizer ||= Authorizer.new(self)
      @authorizer.can?(permission, subject)
    end
  end

  def self.search_by_admin(key, operator, value)
    value      = value == 'true'
    value      = !value if operator == '<>'
    conditions = [self.table_name, Usergroup.table_name].map do |base|
      "(#{base}.admin = ?" + (value ? ')' : " OR #{base}.admin IS NULL)")
    end
    conditions = conditions.join(value ? ' OR ' : ' AND ')

    {
      :include    => :cached_usergroups,
      :conditions => sanitize_sql_for_conditions([conditions, value, value])
    }
  end

  # note that if you assign user new usergroups which change the admin flag you must save
  # the record before #admin? will reflect this
  def admin?
    self[:admin] || cached_usergroups.any?(&:admin?)
  end

  def hidden?
    auth_source.is_a? AuthSourceHidden
  end

  def internal?
    auth_source.is_a? AuthSourceInternal
  end

  def to_label
    name = [firstname, lastname].join(' ')
    name.presence || login
  end
  alias_method :name, :to_label

  def to_param
    Parameterizable.parameterize("#{id}-#{login}")
  end

  def <=>(other)
    self.name.downcase <=> other.name.downcase
  end

  # The text item to see in a select dropdown menu
  def select_title
    name = [firstname, lastname].join(' ')
    name.present? ? "#{name} (#{login})" : login
  end

  def self.anonymous_admin
    unscoped.find_by_login(ANONYMOUS_ADMIN) || raise(Foreman::Exception.new(N_("Anonymous admin user %s is missing, run foreman-rake db:seed"), ANONYMOUS_ADMIN))
  end

  def self.anonymous_api_admin
    unscoped.find_by_login(ANONYMOUS_API_ADMIN) || raise(Foreman::Exception.new(N_("Anonymous admin user %s is missing, run foreman-rake db:seed"), ANONYMOUS_API_ADMIN))
  end

  def self.anonymous_console_admin
    unscoped.find_by_login(ANONYMOUS_CONSOLE_ADMIN) || raise(Foreman::Exception.new(N_("Anonymous admin user %s is missing, run foreman-rake db:seed"), ANONYMOUS_CONSOLE_ADMIN))
  end

  # Tries to find the user in the DB and then authenticate against their authentication source
  # If the user is not in the DB then try to login the user on each available authentication source
  # If this succeeds then copy the user's details from the authentication source into the User table
  # Returns : User object OR nil
  def self.try_to_login(login, password, api_request = false)
    # Make sure no one can sign in with an empty password
    return nil if password.to_s.empty?

    # user is already in local database
    if (user = unscoped.find_by_login(login))
      # user has an authentication method and the authentication was successful
      if api_request && user.authenticate_by_personal_access_token(password)
        logger.debug("Authenticated user #{user.login} with a Personal Access Token.")

        unless user.auth_source.valid_user?(user.login)
          logger.debug "Failed to find #{user.login} in #{user.auth_source} authentication source"
          user = nil
        end
      elsif user.auth_source && (attrs = user.auth_source.authenticate(login, password))
        logger.debug "Authenticated user #{user.login} against #{user.auth_source} authentication source"

        # update with returned attrs, maybe some info changed in LDAP
        old_hash = user.avatar_hash
        User.as_anonymous_admin do
          if attrs.is_a? Hash
            valid_attrs = attrs.slice(:firstname, :lastname, :mail, :avatar_hash).delete_if { |k, v| v.blank? }
            logger.debug("Updating user #{user.login} attributes from auth source: #{attrs.keys}")
            unless user.update(valid_attrs)
              logger.warn "Failed to update #{user.login} attributes: #{user.errors.full_messages.join(', ')}"
            end
          end
          user.auth_source.update_usergroups(user.login)
        end

        # clean up old avatar if it exists and the image isn't in use by anyone else
        if old_hash.present? && user.avatar_hash != old_hash && !User.unscoped.where(:avatar_hash => old_hash).any?
          old_avatar = "#{Rails.public_path}/images/avatars/#{old_hash}.jpg"
          File.delete(old_avatar) if File.exist?(old_avatar)
        end
      else
        logger.debug "Failed to authenticate #{user.login} against #{user.auth_source} authentication source"
        user = nil
      end
    else
      user = try_to_auto_create_user(login, password)
    end
    unless user
      logger.info "invalid user"
      User.current = nil
    end
    user
  end

  def post_successful_login
    logger.debug "Post-login processing for #{login}"
    User.as_anonymous_admin do
      update_columns(:last_login_on => Time.now.utc)
      ensure_default_role
    end
    User.current = self
  end

  def self.find_or_create_external_user(attrs, auth_source_name)
    external_groups = attrs.delete(:groups)
    auth_source = AuthSource.find_by_name(auth_source_name.to_s)

    # existing user, we'll update them
    if (user = unscoped.find_by_login(attrs[:login]))
      # we know this auth source and it's user's auth source, we'll update user attributes
      if auth_source && (user.auth_source_id == auth_source.id)
        auth_source_external_groups = auth_source.external_usergroups.pluck(:usergroup_id)
        new_usergroups = user.usergroups.includes(:external_usergroups).where('usergroups.id NOT IN (?)', auth_source_external_groups)

        new_usergroups += auth_source.external_usergroups.includes(:usergroup).where(:name => external_groups).map(&:usergroup)
        user.update(Hash[attrs.select { |k, v| v.present? }])
        user.usergroups = new_usergroups.uniq
      end

      return true
    # not existing user and creating is disabled by settings
    elsif auth_source_name.nil?
      return false
    # not existing user and auth source is set, we'll create the user and auth source if needed
    else
      User.as_anonymous_admin do
        auth_source = AuthSourceExternal.create!(:name => auth_source_name) if auth_source.nil?
        user = User.create!(attrs.merge(:auth_source => auth_source))
        if external_groups.present?
          user.usergroups = auth_source.external_usergroups.where(:name => external_groups).map(&:usergroup).uniq
        end
        user.post_successful_login
      end
      return true
    end
  end

  def self.find_by_login(login)
    find_by_lower_login(login.to_s.downcase)
  end

  def set_lower_login
    self.lower_login = login.downcase if login.present?
  end

  def self.fetch_ids_by_list(userlist)
    User.where(:lower_login => userlist.map(&:downcase)).pluck(:id)
  end

  def matching_password?(pass)
    self.password_hash == hash_password(pass)
  end

  def my_usergroups
    all_groups = []
    usergroups.each do |usergroup|
      all_groups += usergroup.all_usergroups
    end
    all_groups.uniq
  end

  def indirect_hosts
    my_usergroups.map {|g| g.hosts}.flatten.uniq
  end

  def hosts
    direct_hosts + indirect_hosts
  end

  def recipients
    [mail]
  end

  def mail_enabled?
    mail_enabled && !mail.empty?
  end

  def recipients_for(notification)
    self.receives?(notification) ? [self] : []
  end

  def receives?(notification)
    return false unless mail_enabled?
    self.mail_notifications.include? MailNotification[notification]
  end

  def manage_password?
    return false if self.admin? && !User.current.try(:admin?)
    auth_source&.can_set_password?
  end

  # Return true if the user is allowed to do the specified action
  # action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  def allowed_to?(action)
    return true if admin?
    if action.is_a?(Hash) || action.is_a?(ActionController::Parameters)
      action = Foreman::AccessControl.normalize_path_hash(action)
      return true if editing_self?(action)
    end
    cached_roles.detect {|role| role.allowed_to?(action)}.present?
  end

  def logged?
    true
  end

  # user must be assigned all given roles in order to delegate them
  # or have :escalate_roles permission
  def can_assign?(role_ids)
    can_escalate? || role_ids.all? { |r| self.role_ids_was.include?(r) }
  end

  def can_escalate?
    self.admin? || self.can?(:escalate_roles)
  end

  # only admin can change admin flag
  def can_change_admin_flag?
    self.admin?
  end

  def editing_self?(options = {})
    options[:controller].to_s == 'users' &&
      options[:action] =~ /edit|update/ &&
      options[:id].to_i == self.id ||
    options[:controller].to_s =~ /\Aapi\/v\d+\/users\Z/ &&
      options[:action] =~ /show|update/ &&
      (options[:id].to_i == self.id || options[:id] == self.login) ||
    options[:controller].to_s == 'ssh_keys' &&
      options[:user_id].to_i == self.id &&
      options[:action] =~ /new|create|destroy/ ||
    options[:controller].to_s == 'api/v2/ssh_keys' &&
      options[:action] =~ /show|destroy|index|create/ &&
      options[:user_id].to_i == self.id ||
    options[:controller].to_s == 'api/v2/personal_access_tokens' &&
      options[:action] =~ /show|destroy|index|create/ &&
      options[:user_id].to_i == self.id
  end

  def taxonomy_foreign_conditions
    { :owner_id => id, :owner_type => 'User' }
  end

  def set_current_taxonomies
    ['location', 'organization'].each do |taxonomy|
      default_taxonomy = self.send "default_#{taxonomy}"
      if default_taxonomy.present?
        taxonomy.classify.constantize.send 'current=', default_taxonomy
        session["#{taxonomy}_id"] = default_taxonomy.id
      end
    end

    TopbarSweeper.expire_cache(self)
  end

  def my_organizations
    Organization.my_organizations(self)
  end

  def my_locations
    Location.my_locations(self)
  end

  def taxonomy_ids
    { :organizations => my_organizations.pluck(:id),
      :locations => my_locations.pluck(:id) }
  end

  def visible_environments
    authorized_scope = Environment.unscoped.authorized(:view_environments)
    authorized_scope = authorized_scope
      .joins(:taxable_taxonomies)
      .where('taxable_taxonomies.taxonomy_id' => taxonomy_ids[:organizations] + taxonomy_ids[:locations])
    result = authorized_scope.distinct.pluck(:name)
    if User.current.admin?
      # Admin users can also see Environments that do not have any organization or location, even when
      # organizations and locations are enabled.
      untaxed_environments = Environment.unscoped.where(
        "id NOT IN (
          SELECT DISTINCT(taxable_id) FROM taxable_taxonomies
            WHERE taxable_type='Environment'
          )").pluck(:name)
      result += untaxed_environments
    end
    result
  end

  def taxonomy_and_child_ids(taxonomies)
    ids = []
    send(taxonomies).each do |taxonomy|
      ids += taxonomy.subtree_ids
    end
    ids.uniq
  end

  def location_and_child_ids
    taxonomy_and_child_ids(:locations)
  end

  def organization_and_child_ids
    taxonomy_and_child_ids(:organizations)
  end

  def self.random_password(size = 16)
    set = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a - %w(0 1 O I l)
    Array.new(size) { set.sample }.join
  end

  def expire_topbar_cache
    TopbarSweeper.expire_cache(self)
  end

  def external_usergroups
    usergroups.flat_map(&:external_usergroups).select { |group| group.auth_source == self.auth_source }
  end

  def self.try_to_auto_create_user(login, password)
    return if login.blank? || password.blank?
    # User is not yet registered, try to authenticate with available sources
    logger.debug "Attempting to log into an auth source as #{login} for account auto-creation"
    return unless (attrs = AuthSource.authenticate(login, password))

    attrs.delete(:dn)
    user = new(attrs)
    # Inherit taxonomies from authentication source on creation
    auth_source = AuthSource.find(attrs[:auth_source_id])
    user.locations = auth_source.locations
    user.organizations = auth_source.organizations

    # If an invalid data returned from an authentication source for any attribute(s) then set its value as nil
    saved_attrs = {}
    unless user.valid?
      user.errors.each do |attr|
        saved_attrs[attr] = user[attr]
        user[attr] = nil
      end
    end

    # The default user can't auto create users, we need to change to Admin for this to work
    User.as_anonymous_admin do
      if user.save
        auth_source.update_usergroups(user.login)
        logger.info "User '#{user.login}' auto-created from #{user.auth_source}"
      else
        logger.info "Failed to save User '#{user.login}' #{user.errors.full_messages}"
        user = nil
      end
    end

    # Restore any invalid attributes after creation, so the method returns a saved user object but
    # any errors from invalid data are still visible to the caller
    user.attributes = saved_attrs
    user.valid?

    user
  end

  def fullname
    [firstname, lastname].delete_if(&:blank?).join(' ')
  end

  def to_export
    { login => super }
  end

  def notification_recipients_ids
    [self.id]
  end

  def authenticate_by_personal_access_token(token)
    PersonalAccessToken.authenticate_user(self, token)
  end

  private

  def prepare_password
    if password.present?
      self.password_salt = Digest::SHA1.hexdigest([Time.now.utc, rand].join)
      self.password_hash = hash_password(password)
    end
  end

  def welcome_mail
    return unless mail_enabled? && internal? && Setting[:send_welcome_email]
    MailNotification[:welcome].deliver(:user => self)
  end

  def hash_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end

  def normalize_locale
    self.locale = nil if self.respond_to?(:locale) && locale.empty?
  end

  def normalize_timezone
    self.timezone = nil if timezone.blank?
  end

  def normalize_mail
    self.mail = mail.strip if mail.present?
  end

  def reject_empty_intervals(attributes)
    user_mail_notification_exists = attributes[:id].present?
    interval_empty = attributes[:interval].blank?
    attributes[:_destroy] = 1 if user_mail_notification_exists && interval_empty
    (!user_mail_notification_exists && interval_empty)
  end

  def set_default_widgets
    Dashboard::Manager.reset_user_to_default(self)
  end

  def verify_current_password
    unless self.matching_password?(current_password)
      errors.add :current_password, _("Incorrect password")
    end
  end

  protected

  def name_used_in_a_usergroup
    if Usergroup.where(:name => self.login).present?
      errors.add(:base, _("A user group already exists with this name"))
    end
  end

  def ensure_last_admin_is_not_deleted
    if admin && User.unscoped.only_admin.except_hidden.size <= 1
      errors.add :base, _("Can't delete the last admin account")
      logger.warn "Unable to delete the last admin account"
      throw :abort
    end
  end

  def ensure_last_admin_remains_admin
    if !new_record? && admin_changed? && !admin && User.unscoped.only_admin.except_hidden.size <= 1
      errors.add :admin, _("cannot be removed from the last admin account")
      logger.warn "Unable to remove admin privileges from the last admin account"
      false
    end
  end

  # The hidden/internal admin accounts are always required
  def ensure_hidden_users_are_not_deleted
    if auth_source.is_a? AuthSourceHidden
      errors.add :base, _("Can't delete internal admin account")
      logger.warn "Unable to delete internal admin account"
      throw :abort
    end
  end

  # The hidden accounts must always retain the "Administrator" flag to function
  def ensure_hidden_users_remain_admin
    if auth_source.is_a?(AuthSourceHidden) && admin_changed? && !admin
      errors.add :admin, _("cannot be removed from an internal protected account")
    end
  end

  def ensure_hidden_users_are_not_renamed
    if auth_source.is_a?(AuthSourceHidden) && login_changed? && !new_record?
      errors.add :login, _("cannot be changed on an internal protected account")
    end
  end

  def ensure_privileges_not_escalated
    ensure_admin_not_escalated
    ensure_roles_not_escalated
  end

  def ensure_roles_not_escalated
    roles_check = self.new_record? ? self.role_ids.present? : self.role_ids_changed?
    if roles_check && !User.current.can_assign?(self.role_ids)
      errors.add :role_ids, _("you can't assign some of roles you selected")
    end
  end

  def ensure_admin_not_escalated
    admin_check = self.new_record? ? self.admin? : self.admin_changed?
    if admin_check && !User.current.can_change_admin_flag?
      errors.add :admin, _("you can't change administrator flag")
    end
  end

  def ensure_default_role
    default_role = Role.default
    self.roles << default_role unless self.roles.include?(default_role)
  end

  def ensure_admin_password_changed_by_admin
    if (self.admin && !User.current.try(:admin?)) && password_hash_changed?
      errors.add :password, _('cannot be changed by a non-admin user')
    end
  end

  def default_location_inclusion
    unless locations.include?(default_location) || default_location.blank? || self.admin?
      errors.add :default_location, _("default locations need to be user locations first")
    end
  end

  def default_organization_inclusion
    unless organizations.include?(default_organization) || default_organization.blank? || self.admin?
      errors.add :default_organization, _("default organizations need to be user organizations first")
    end
  end

  def hidden_authsource_restricted
    if auth_source_id_changed? && hidden? && ![ANONYMOUS_ADMIN, ANONYMOUS_API_ADMIN, ANONYMOUS_CONSOLE_ADMIN].include?(self.login)
      errors.add :auth_source, _("is not permitted")
    end
  end

  def check_permissions_for_changing_login
    if login_changed? && !self.new_record?
      if !self.internal?
        errors.add :login, _("It is not possible to change external users login")
      elsif !(User.current.can?(:edit_users, self) || (self.id == User.current.id))
        errors.add :login, _("You do not have permission to edit the login")
      end
    end
  end
end
