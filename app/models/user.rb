require 'digest/sha1'
require 'foreman/thread_session'

class User < ActiveRecord::Base
  include Authorization
  include Foreman::ThreadSession::UserModel
  include Taxonomix
  audited :except => [:last_login_on, :password, :password_hash, :password_salt, :password_confirmation]
  self.auditing_enabled = !(File.basename($0) == "rake" && ARGV.include?("db:migrate"))

  attr_protected :password_hash, :password_salt, :admin
  attr_accessor :password, :password_confirmation, :editing_self

  belongs_to :auth_source
  has_many :auditable_changes, :class_name => '::Audit', :as => :user
  has_many :usergroup_member, :as => :member, :dependent => :destroy
  has_many :usergroups, :through => :usergroup_member
  has_many :direct_hosts, :as => :owner, :class_name => "Host"
  has_and_belongs_to_many :notices, :join_table => 'user_notices'
  has_many :user_roles
  has_many :roles, :through => :user_roles
  has_and_belongs_to_many :compute_resources, :join_table => "user_compute_resources"
  has_and_belongs_to_many :domains,           :join_table => "user_domains"
  has_many :user_hostgroups
  has_many :hostgroups, :through => :user_hostgroups
  has_many :user_facts, :dependent => :destroy
  has_many :facts, :through => :user_facts, :source => :fact_name

  scope :except_admin, where(:admin => false)
  scope :only_admin, where(:admin => true)

  accepts_nested_attributes_for :user_facts, :reject_if => lambda { |a| a[:criteria].blank? }, :allow_destroy => true

  validates :mail, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)*[a-z]{2,})$/i },
                   :length => { :maximum => 60 },
                   :allow_blank => true
  validates :mail, :presence => true, :on => :update

  validates_uniqueness_of :login, :message => _("already exists")
  validates_presence_of :login, :auth_source_id
  validates_presence_of :password_hash, :if => Proc.new {|user| user.manage_password?}
  validates_confirmation_of :password,  :if => Proc.new {|user| user.manage_password?}, :unless => Proc.new {|user| user.password.empty?}
  validates_format_of :login, :with => /^[a-z0-9_\-@\.]*$/i
  validates_length_of :login, :maximum => 100
  validates_format_of :firstname, :lastname, :with => /^[\w\s\'\-\.]*$/i, :allow_nil => true
  validates_length_of :firstname, :lastname, :maximum => 30, :allow_nil => true

  before_destroy EnsureNotUsedBy.new(:hosts), :ensure_admin_is_not_deleted
  validate :name_used_in_a_usergroup, :ensure_admin_is_not_renamed
  before_validation :prepare_password, :normalize_mail
  after_destroy Proc.new {|user| user.compute_resources.clear; user.domains.clear; user.hostgroups.clear}

  scoped_search :on => :login, :complete_value => :true
  scoped_search :on => :firstname, :complete_value => :true
  scoped_search :on => :lastname, :complete_value => :true
  scoped_search :on => :mail, :complete_value => :true
  scoped_search :on => :admin, :complete_value => {:true => true, :false => false}
  scoped_search :on => :last_login_on, :complete_value => :true
  scoped_search :in => :roles, :on => :name, :rename => :role, :complete_value => true

  default_scope lambda {
    with_taxonomy_scope do
      order('firstname')
    end
  }

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

  def self.create_admin
    email = Setting[:administrator]
    user = User.new(:login => "admin", :firstname => "Admin", :lastname => "User",
                       :mail => email, :auth_source => AuthSourceInternal.first, :password => "changeme")
    user.update_attribute :admin, true
    old_current = User.current
    User.current = user
    user.save!
    user
  ensure
    User.current = old_current
  end

  def self.admin
    unscoped.find_by_login 'admin' or create_admin
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
      if user.auth_source and user.auth_source.authenticate(login, password)
        logger.debug "Authenticated user #{user} against #{user.auth_source} authentication source"
      else
        logger.debug "Failed to authenticate #{user} against #{user.auth_source} authentication source"
        user = nil
      end
    else
      user = try_to_auto_create_user(login, password)
    end
    if user
      as "admin" do
        user.update_attribute(:last_login_on, Time.now.utc)
        anonymous = Role.find_by_name("Anonymous")
        user.roles << anonymous unless user.roles.include?(anonymous)
        User.current = user
      end
    else
      logger.info "invalid user"
      User.current = nil
    end
    user
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
  def allowed_to?(action, options={})
    return true if admin?
    return true if editing_self
    roles.detect {|role| role.allowed_to?(action)}.present?
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
      User.as "admin" do
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

  def normalize_mail
    self.mail.gsub!(/\s/,'') unless mail.blank?
  end

  protected

  def name_used_in_a_usergroup
    if Usergroup.all.map(&:name).include?(self.login)
      errors.add(:base, _("A user group already exists with this name"))
    end
  end

  # The internal Admin Account is always available
  # this is required as when not using external authentication, the systems logs you in with the
  # admin account automatically
  def ensure_admin_is_not_deleted
    if login == "admin"
      errors.add :base, "Can't delete internal admin account"
      logger.warn "Unable to delete internal admin account"
      false
    end
  end

  def ensure_admin_is_not_renamed
    if login_changed? and login_was == "admin"
      errors.add :login, "Can't rename internal protected <b>admin</b> account to #{login}".html_safe
    end
  end
end
