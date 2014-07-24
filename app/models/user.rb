# encoding: UTF-8
require 'digest/sha1'

class User < ActiveRecord::Base
  include Authorizable
  include Foreman::ThreadSession::UserModel
  include Taxonomix
  audited :except => [:last_login_on, :password, :password_hash, :password_salt, :password_confirmation], :allow_mass_assignment => true
  self.auditing_enabled = !Foreman.in_rake?('db:migrate')

  ANONYMOUS_ADMIN = 'foreman_admin'
  ANONYMOUS_API_ADMIN = 'foreman_api_admin'

  attr_protected :password_hash, :password_salt, :admin
  attr_accessor :password, :password_confirmation
  after_save :ensure_default_role
  before_destroy EnsureNotUsedBy.new(:direct_hosts, :hostgroups), :ensure_hidden_users_are_not_deleted, :ensure_last_admin_is_not_deleted

  belongs_to :auth_source
  belongs_to :default_organization, :class_name => 'Organization'
  belongs_to :default_location,     :class_name => 'Location'

  has_many :auditable_changes, :class_name => '::Audit', :as => :user
  has_many :direct_hosts,      :class_name => 'Host',    :as => :owner
  has_many :usergroup_member,  :dependent => :destroy,   :as => :member
  has_many :user_roles,        :dependent => :destroy, :foreign_key => 'owner_id', :conditions => {:owner_type => self.to_s}
  has_many :user_hostgroups
  has_many :user_facts,        :dependent => :destroy
  has_many :cached_user_roles, :dependent => :destroy
  has_many :facts,             :through => :user_facts,               :source => :fact_name
  has_many :cached_usergroups, :through => :cached_usergroup_members, :source => :usergroup
  has_many :cached_roles,      :through => :cached_user_roles,        :source => :role, :uniq => true
  has_many :hostgroups,        :through => :user_hostgroups
  has_many :usergroups,        :through => :usergroup_member, :dependent => :destroy
  has_many :roles,             :through => :user_roles,       :dependent => :destroy
  has_many :filters,           :through => :cached_roles
  has_many :permissions,       :through => :filters
  has_many :cached_usergroup_members

  has_and_belongs_to_many :notices,           :join_table => 'user_notices'
  has_and_belongs_to_many :compute_resources, :join_table => "user_compute_resources"
  has_and_belongs_to_many :domains,           :join_table => "user_domains"
  attr_name :login

  scope :except_admin, lambda {
    includes(:cached_usergroups).
        where(["(#{self.table_name}.admin = ? OR #{self.table_name}.admin IS NULL) AND " +
                   "(#{Usergroup.table_name}.admin = ? OR #{Usergroup.table_name}.admin IS NULL)",
               false, false])
  }
  scope :only_admin, lambda {
    includes(:cached_usergroups).
        where(["#{self.table_name}.admin = ? OR #{Usergroup.table_name}.admin = ?", true, true])
  }
  scope :except_hidden, lambda {
    if (hidden = AuthSourceHidden.all).present?
      where("#{self.table_name}.auth_source_id <> ?", hidden)
    end
  }

  accepts_nested_attributes_for :user_facts, :reject_if => lambda { |a| a[:criteria].blank? }, :allow_destroy => true

  validates :mail, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)*[a-z]{2,})\Z/i },
                   :length => { :maximum => 60 },
                   :allow_blank => true
  validates :mail, :presence => true, :on => :update,
                   :if => Proc.new { |u| !AuthSourceHidden.where(:id => u.auth_source_id).any? }

  validates :locale, :format => { :with => /\A\w{2}([_-]\w{2})?\Z/ }, :allow_blank => true, :if => Proc.new { |user| user.respond_to?(:locale) }
  before_validation :normalize_locale

  def self.name_format
    if RUBY_VERSION.start_with? '1.8'
      /\A[ёЁа-яА-Яa-zA-Zà-üÀ-Ü0-9\s'_\-\.()<>;=,]*\z/u
    else
      /\A[[:alnum:]\s'_\-\.()<>;=,]*\z/
    end
  end

  validates :login, :presence => true, :uniqueness => {:message => N_("already exists")},
                    :format => {:with => /\A[[:alnum:]_\-@\.]*\Z/}, :length => {:maximum => 100}
  validates :auth_source_id, :presence => true
  validates :password_hash, :presence => true, :if => Proc.new {|user| user.manage_password?}
  validates_confirmation_of :password,  :if => Proc.new {|user| user.manage_password?}, :unless => Proc.new {|user| user.password.empty?}
  validates :firstname, :lastname, :format => {:with => name_format}, :length => {:maximum => 50}, :allow_nil => true
  validate :name_used_in_a_usergroup, :ensure_hidden_users_are_not_renamed, :ensure_hidden_users_remain_admin,
           :ensure_privileges_not_escalated, :default_organization_inclusion, :default_location_inclusion,
           :ensure_last_admin_remains_admin, :hidden_authsource_restricted
  before_validation :prepare_password, :normalize_mail
  after_destroy Proc.new {|user| user.compute_resources.clear; user.domains.clear; user.hostgroups.clear}

  scoped_search :on => :login, :complete_value => :true
  scoped_search :on => :firstname, :complete_value => :true
  scoped_search :on => :lastname, :complete_value => :true
  scoped_search :on => :mail, :complete_value => :true
  scoped_search :on => :admin, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_admin
  scoped_search :on => :last_login_on, :complete_value => :true, :only_explicit => true
  scoped_search :in => :roles, :on => :name, :rename => :role, :complete_value => true
  scoped_search :in => :cached_usergroups, :on => :name, :rename => :usergroup, :complete_value => true

  default_scope lambda {
    with_taxonomy_scope.except_hidden do
      order('firstname')
    end
  }

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
    read_attribute(:admin) || cached_usergroups.any?(&:admin?)
  end

  def hidden?
    auth_source.kind_of? AuthSourceHidden
  end

  def to_label
    (firstname.present? || lastname.present?) ? "#{firstname} #{lastname}" : login
  end
  alias_method :name, :to_label

  def to_param
    "#{id}-#{login.parameterize}"
  end

  def <=>(other)
    self.name.downcase <=> other.name.downcase
  end

  # The text item to see in a select dropdown menu
  def select_title
    to_label + " (#{login})"
  end

  def self.anonymous_admin
    unscoped.find_by_login ANONYMOUS_ADMIN or raise Foreman::Exception.new(N_("Anonymous admin user %s is missing, run foreman-rake db:seed", ANONYMOUS_ADMIN))
  end

  def self.anonymous_api_admin
    unscoped.find_by_login ANONYMOUS_API_ADMIN or raise Foreman::Exception.new(N_("Anonymous admin user %s is missing, run foreman-rake db:seed", ANONYMOUS_API_ADMIN))
  end

  # Tries to find the user in the DB and then authenticate against their authentication source
  # If the user is not in the DB then try to login the user on each available authentication source
  # If this succeeds then copy the user's details from the authentication source into the User table
  # Returns : User object OR nil
  def self.try_to_login(login, password)
    # Make sure no one can sign in with an empty password
    return nil if password.to_s.empty?

    # user is already in local database
    if (user = unscoped.find_by_login(login))
      # user has an authentication method and the authentication was successful
      if user.auth_source and attrs=user.auth_source.authenticate(login, password)
        logger.debug "Authenticated user #{user} against #{user.auth_source} authentication source"

        # update with returned attrs, maybe some info changed in LDAP
        old_hash = user.avatar_hash
        User.as_anonymous_admin do
          user.update_attributes(attrs.slice(:firstname, :lastname, :mail, :avatar_hash).delete_if { |k, v| v.blank? })
        end if attrs.is_a? Hash

        # clean up old avatar if it exists and the image isn't in use by anyone else
        if old_hash.present? && user.avatar_hash != old_hash && !User.unscoped.where(:avatar_hash => old_hash).any?
          File.delete "#{Rails.public_path}/avatars/#{old_hash}.jpg" if File.exist? old_avatar
        end
      else
        logger.debug "Failed to authenticate #{user} against #{user.auth_source} authentication source"
        user = nil
      end
    else
      user = try_to_auto_create_user(login, password)
    end
    if user
      user.post_successful_login
    else
      logger.info "invalid user"
      User.current = nil
    end
    user
  end

  def post_successful_login
    User.as_anonymous_admin do
      self.update_attribute(:last_login_on, Time.now.utc)
      anonymous = Role.find_by_name("Anonymous")
      self.roles << anonymous unless self.roles.include?(anonymous)
    end
    User.current = self
  end

  def self.find_or_create_external_user(attrs, auth_source_name)
    external_groups = attrs.delete(:groups)
    auth_source = AuthSource.find_by_name(auth_source_name)

    # existing user, we'll update them
    if (user = unscoped.find_by_login(attrs[:login]))
      # we know this auth source and it's user's auth source, we'll update user attributes
      if auth_source && (user.auth_source_id == auth_source.id)
        auth_source_external_groups = auth_source.external_usergroups.pluck(:usergroup_id)
        new_usergroups = user.usergroups.includes(:external_usergroups).where('usergroups.id NOT IN (?)', auth_source_external_groups)

        new_usergroups += auth_source.external_usergroups.includes(:usergroup).where(:name => external_groups).map(&:usergroup)
        user.update_attributes(Hash[attrs.select { |k, v| v.present? }])
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

  def matching_password?(pass)
    self.password_hash == encrypt_password(pass)
  end

  def my_usergroups
    all_groups = []
    for usergroup in usergroups
      all_groups += usergroup.all_usergroups
    end
    all_groups.uniq
  end

  def indirect_hosts
    my_usergroups.map{|g| g.hosts}.flatten.uniq
  end

  def hosts
    direct_hosts + indirect_hosts
  end

  def recipients
    [mail]
  end

  def manage_password?
    auth_source and auth_source.can_set_password?
  end

  # Return true if the user is allowed to do the specified action
  # action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  def allowed_to?(action)
    return true if admin?
    if action.is_a? Hash
      # normalize controller name
      action[:controller] = action[:controller].to_s.gsub(/::/, "_").sub(/^\//,'').underscore
      return true if editing_self?(action)
    end
    cached_roles.detect {|role| role.allowed_to?(action)}.present?
  end

  def logged?
    true
  end

  # Indicates whether the user has host filtering enabled
  # Returns : Boolean
  def filtering?
    filter_on_owner        or
    compute_resources.any? or
    domains.any?           or
    hostgroups.any?        or
    facts.any?             or
    locations.any?         or
    organizations.any?
  end

  # user must be assigned all given roles in order to delegate them
  def can_assign?(roles)
    can_change_admin_flag? || roles.all? { |r| self.role_ids_was.include?(r) }
  end

  # only admin can change admin flag
  def can_change_admin_flag?
    self.admin?
  end

  def role_ids_with_change_detection=(roles)
    roles ||= [] # in API, role_ids is converted to nil if user sent empty array
    @role_ids_changed = roles.uniq.select(&:present?).map(&:to_i).sort != role_ids.sort
    @role_ids_was = role_ids.clone
    self.role_ids_without_change_detection = roles
  end
  alias_method_chain(:role_ids=, :change_detection)

  def role_ids_changed?
    @role_ids_changed
  end

  def role_ids_was
    @role_ids_was ||= role_ids
  end

  def editing_self?(options = {})
    options[:controller].to_s == 'users' &&
      options[:action] =~ /edit|update/ &&
      options[:id].to_i == self.id
  end

  def taxonomy_foreign_conditions
    { :owner_id => id }
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

  def taxonomy_and_child_ids(taxonomies)
    ids = []
    send(taxonomies).each do |taxonomy|
      ids += taxonomy.subtree_ids
    end
    return ids.uniq
  end

  def location_and_child_ids
    taxonomy_and_child_ids(:locations)
  end

  def organization_and_child_ids
    taxonomy_and_child_ids(:organizations)
  end

  def self.random_password(size = 16)
    set = ('a' .. 'z').to_a + ('A' .. 'Z').to_a + ('0' .. '9').to_a - %w(0 1 O I l)
    size.times.collect {|i| set[rand(set.size)] }.join
  end

  def expire_topbar_cache(sweeper)
    sweeper.expire_fragment(TopbarSweeper.fragment_name(id))
  end

  private

  def prepare_password
    unless password.blank?
      self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
      self.password_hash = encrypt_password(password)
    end
  end

  def encrypt_password(pass)
    Digest::SHA1.hexdigest([pass, password_salt].join)
  end

  def self.try_to_auto_create_user(login, password)
    return nil if login.blank? or password.blank?

    # user is not yet registered, try to authenticate with available sources
    if (attrs = AuthSource.authenticate(login, password))
      user = new(attrs)
      user.login = login
      # The default user can't auto create users, we need to change to Admin for this to work
      User.as_anonymous_admin do
        if user.save
          logger.info "User '#{user.login}' auto-created from #{user.auth_source}"
        else
          logger.info "Failed to save User '#{user.login}' #{user.errors.full_messages}"
          user = nil
        end
      end
      user
    end
  end

  def normalize_locale
    if self.respond_to?(:locale)
      self.locale = nil if locale.empty?
    end
  end

  def normalize_mail
    self.mail.gsub!(/\s/,'') unless mail.blank?
  end

  protected

  def name_used_in_a_usergroup
    if Usergroup.all.map(&:name).include?(self.login)
      errors.add(:base, _("A user group already exists with this name"))
    end
  end

  def ensure_last_admin_is_not_deleted
    if admin && User.unscoped.only_admin.except_hidden.size <= 1
      errors.add :base, _("Can't delete the last admin account")
      logger.warn "Unable to delete the last admin account"
      false
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
      false
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
      errors.add :role_ids, _("You can't assign some of roles you selected")
    end
  end

  def ensure_admin_not_escalated
    admin_check = self.new_record? ? self.admin? : self.admin_changed?
    if admin_check && !User.current.can_change_admin_flag?
      errors.add :admin, _("You can't change Administrator flag")
    end
  end

  def ensure_default_role
    role = Role.find_by_name('Anonymous')
    if role.present?
      self.roles << role unless self.role_ids.include?(role.id)
    end
  end

  def default_location_inclusion
    unless locations.include?(default_location) || default_location.blank? || self.admin?
      errors.add :default_location, _("Default locations need to be user locations first")
    end
  end

  def default_organization_inclusion
    unless organizations.include?(default_organization) || default_organization.blank? || self.admin?
      errors.add :default_organization, _("Default organizations need to be user organizations first")
    end
  end

  def hidden_authsource_restricted
    if auth_source_id_changed? && hidden? && ![ANONYMOUS_ADMIN, ANONYMOUS_API_ADMIN].include?(self.login)
      errors.add :auth_source, _("is not permitted")
    end
  end
end
