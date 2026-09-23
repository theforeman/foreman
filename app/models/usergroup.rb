class Usergroup < ApplicationRecord
  audited :associations => [:usergroups, :roles, :users]
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include TopbarCacheExpiry
  include UserUsergroupCommon
  include Taxonomix

  validates_lengths_from_database
  validates_associated :external_usergroups
  before_destroy EnsureNotUsedBy.new(:hosts), :ensure_last_admin_group_is_not_deleted
  before_save :invalidate_members_taxonomy_cache, :if => -> { organization_ids_changed? || location_ids_changed? }

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

  # Organizations and locations on a user group are inherited by its members.
  # They do not scope access to the user group record itself.
  def self.allows_taxonomy_filtering?(_taxonomy)
    false
  end

  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :on => :name, :complete_value => :true
  scoped_search :relation => :roles, :on => :name, :rename => :role, :complete_value => true
  scoped_search :relation => :roles, :on => :id, :rename => :role_id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  validate :ensure_uniq_name, :ensure_last_admin_remains_admin
  validate :admin_can_be_set, :if => ->(o) { o.changed.include?('admin') }
  validate :ensure_roles_not_escalated

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
    all_cached_users.each(&:expire_topbar_cache)
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

  def taxonomy_foreign_conditions
    { :owner_id => id, :owner_type => 'Usergroup' }
  end

  protected

  def allow_empty_taxonomy_selection?
    true
  end

  def invalidate_members_taxonomy_cache
    all_cached_users.each(&:invalidate_cache)
  end

  def all_cached_users
    User.unscoped.
      joins(:cached_usergroup_members).
      where(:cached_usergroup_members => { :usergroup_id => id }).
      distinct
  end

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

  def admin_can_be_set
    errors.add :admin, _('admin flag can only be modified by admins') unless User.current.admin?
  end

  def ensure_roles_not_escalated
    return if User.current.nil?

    roles_check = new_record? ? role_ids.present? : role_ids_changed?
    if roles_check
      new_role_ids = new_record? ? role_ids : role_ids - role_ids_was
      unless User.current.can_assign_for_usergroup?(role_ids, self, new_role_ids)
        errors.add :role_ids, _("you can't assign some of roles you selected")
      end
    end
  end
end
