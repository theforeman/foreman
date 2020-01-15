class Usergroup < ApplicationRecord
  audited :associations => [:usergroups, :roles, :users]
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include TopbarCacheExpiry
  include UserUsergroupCommon

  validates_lengths_from_database
  validates_associated :external_usergroups
  before_destroy EnsureNotUsedBy.new(:hosts), :ensure_last_admin_group_is_not_deleted

  has_many :user_roles, :dependent => :destroy, :as => :owner
  has_many :roles, :through => :user_roles, :dependent => :destroy

  has_many :usergroup_members, :dependent => :destroy
  has_many :users,      :through => :usergroup_members, :source => :member, :source_type => 'User', :dependent => :destroy
  has_many :usergroups, :through => :usergroup_members, :source => :member, :source_type => 'Usergroup', :dependent => :destroy
  has_many :external_usergroups, :dependent => :destroy, :inverse_of => :usergroup

  has_many :cached_usergroup_members, :foreign_key => 'usergroup_id'
  has_many :cached_users, :through => :cached_usergroup_members, :source => :user
  has_many :cached_usergroups, :through => :cached_usergroup_members, :source => :usergroup
  has_many :usergroup_parents, -> { where("member_type = 'Usergroup'") }, :dependent => :destroy,
           :foreign_key => 'member_id', :class_name => 'UsergroupMember'
  has_many :parents,    :through => :usergroup_parents, :source => :usergroup, :dependent => :destroy

  has_many_hosts :as => :owner

  validates :name, :uniqueness => true, :presence => true

  # The text item to see in a select dropdown menu
  alias_attribute :select_title, :to_s
  default_scope -> { order('usergroups.name') }
  scope :visible, -> {}
  scope :except_current, ->(current) { where.not(:id => current.id) }
  scoped_search :on => :name, :complete_value => :true
  scoped_search :relation => :roles, :on => :name, :rename => :role, :complete_value => true
  scoped_search :relation => :roles, :on => :id, :rename => :role_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  validate :ensure_uniq_name, :ensure_last_admin_remains_admin

  accepts_nested_attributes_for :external_usergroups, :reject_if => ->(a) { a[:name].blank? }, :allow_destroy => true

  class Jail < ::Safemode::Jail
    allow :id, :ssh_keys, :all_users, :ssh_authorized_keys
  end

  # This methods retrieves all user addresses in a usergroup
  # Returns: Array of strings representing the user's email addresses
  def recipients
    all_users.map(&:mail).flatten.uniq.sort
  end

  def recipients_for(notification)
    all_users.select { |user| user if user.receives?(notification) }.uniq.sort
  end

  # This methods retrieves all users in a usergroup
  # Returns: Array of users
  def all_users(group_list = [self], user_list = [])
    retrieve_users_and_groups group_list, user_list
    user_list.uniq.sort
  end

  # This methods retrieves all usergroups in a usergroup
  # Returns: Array of unique usergroups
  def all_usergroups(group_list = [self], user_list = [])
    retrieve_users_and_groups group_list, user_list
    group_list.uniq.sort
  end

  def expire_topbar_cache
    users.each { |u| u.expire_topbar_cache }
  end

  def to_export
    cached_users.includes(:ssh_keys).map(&:to_export).reduce({}, :merge)
  end

  def ssh_keys
    all_users.flat_map(&:ssh_keys)
  end

  def notification_recipients_ids
    all_users.map(&:id)
  end

  protected

  # Recurses down the tree of usergroups and finds the users
  # [+group_list+]: Array of Usergroups that have already been processed
  # [+users+]     : Array of users accumulated at this point
  # Returns       : Array of non unique users
  def retrieve_users_and_groups(group_list, user_list)
    usergroups.each do |group|
      next if group_list.include? group
      group_list << group

      group.retrieve_users_and_groups(group_list, user_list)
    end
    user_list.concat users
  end

  def ensure_uniq_name
    errors.add :name, _("is already used by a user account") if User.find_by(:login => name)
  end

  def ensure_last_admin_remains_admin
    if !new_record? && admin_changed? && !admin && other_admins.empty?
      errors.add :admin, _("cannot be removed from the last admin account")
      logger.warn "Unable to remove admin privileges from the last admin account"
      false
    end
  end

  def ensure_last_admin_group_is_not_deleted
    if admin? && other_admins.empty?
      errors.add :base, _("Can't delete the last admin user group")
      logger.warn "Unable to delete the last admin user group"
      throw :abort
    end
  end

  def other_admins
    User.unscoped.only_admin.except_hidden - all_users
  end
end
