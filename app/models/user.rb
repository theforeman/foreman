require 'digest/sha1'

class User < ActiveRecord::Base
  include Authorization
  attr_protected :password_hash, :password_salt, :admin
  attr_accessor :password, :password_confirmation

  belongs_to :auth_source
  has_many :changes, :class_name => 'Audit', :as => :user
  has_many :usergroups, :through => :usergroup_member
  has_many :direct_hosts, :as => :owner, :class_name => "Host"
  has_and_belongs_to_many :notices, :join_table => 'user_notices'
  has_many :user_roles
  has_many :roles, :through => :user_roles
  has_and_belongs_to_many :domains,    :join_table => "user_domains"
  has_and_belongs_to_many :hostgroups, :join_table => "user_hostgroups"
  has_many :user_facts, :dependent => :destroy
  has_many :facts, :through => :user_facts, :source => :fact_name

  accepts_nested_attributes_for :user_facts, :reject_if => lambda { |a| a[:criteria].blank? }, :allow_destroy => true

  validates_uniqueness_of :login, :message => "already exists"
  validates_presence_of :login, :mail, :auth_source_id
  validates_presence_of :password_hash, :if => Proc.new {|user| user.manage_password?}
  validates_confirmation_of :password,  :if => Proc.new {|user| user.manage_password?}, :unless => Proc.new {|user| user.password.empty?}
  validates_format_of :login, :with => /^[a-z0-9_\-@\.]*$/i
  validates_length_of :login, :maximum => 30
  validates_format_of :firstname, :lastname, :with => /^[\w\s\'\-\.]*$/i, :allow_nil => true
  validates_length_of :firstname, :lastname, :maximum => 30, :allow_nil => true
  validates_format_of :mail, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_nil => true
  validates_length_of :mail, :maximum => 60, :allow_nil => true

  before_destroy Ensure_not_used_by.new(:hosts), :ensure_admin_is_not_deleted
  validate :name_used_in_a_usergroup
  before_validation :prepare_password
  after_destroy Proc.new {|user| user.domains.clear; user.hostgroups.clear}

  cattr_accessor :current

  def to_label
    "#{firstname} #{lastname}"
  end
  alias_method :name, :to_label

  def <=>(other)
    self.name.downcase <=> other.name.downcase
  end

  # The text item to see in a select dropdown menu
  def select_title
    to_label + " (#{login})"
  end

  def self.create_admin
    email = SETTINGS[:administrator] || "root@" + Facter.domain
    user = User.create(:login => "admin", :firstname => "Admin", :lastname => "User",
                       :mail => email, :auth_source => AuthSourceInternal.first, :password => "changeme")
    user.update_attribute :admin, true
    user
  end

  # Tries to find the user in the DB and then authenticate against their authentication source
  # If the user is not in the DB then try to login the user on each available athentication source
  # If this succeeds then copy the user's details from the authentication source into the User table
  # Returns : User object OR nil
  def self.try_to_login(login, password)
    # Make sure no one can sign in with an empty password
    return nil if password.to_s.empty?

    if user = find_by_login(login)
      # user is already in local database
      if user.auth_source and user.auth_source.authenticate(login, password)
        # user has an authentication method and the authentication was successful
        User.current = user
        user.update_attribute(:last_login_on, Time.now.utc)
      else
        user = nil
      end
    else
      # user is not yet registered, try to authenticate with available sources
      attrs = AuthSource.authenticate(login, password)
      if attrs
        user = new(*attrs)
        # The default user must be given :create_users permissions for on-the-fly to work.
        user.login = login
        User.current = user
        if user.save
          user.reload
          logger.info "User '#{user.login}' auto-created from #{user.auth_source}"
          user.update_attribute(:last_login_on, Time.now.utc)
        else
          logger.info "Failed to save User '#{user.login}' #{user.errors.full_messages}"
          user = nil
        end
      end
    end
    anonymous = Role.find_by_name("Anonymous")
    User.current.roles <<  anonymous unless user.nil? or User.current.roles.include?(anonymous)
    return user
  rescue => text
    raise text
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

    return false if roles.empty?
    roles.detect {|role| role.allowed_to?(action)}
  end

  def logged?
    true
  end

  # Indicates whether the user has host filtering enabled
  # Returns : Boolean
  def filtering?
    filter_on_owner or
    domains.any?    or
    hostgroups.any? or
    facts.any?
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

  protected

  def name_used_in_a_usergroup
    if Usergroup.all.map(&:name).include?(self.login)
      errors.add_to_base "A usergroup already exists with this name"
    end
  end

  # The internal Admin Account is always available
  # this is required as when not using external authentication, the systems logs you in with the
  # admin account automatically
  def ensure_admin_is_not_deleted
    if login == "admin"
      errors.add_to_base "Can't delete internal admin account"
      logger.warn "Unable to delete internal admin account"
      return false
    end
  end

end
