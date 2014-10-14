class Usergroup < ActiveRecord::Base
  audited :allow_mass_assignment => true
  include Authorizable
  extend FriendlyId
  friendly_id :name

  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts), :ensure_last_admin_group_is_not_deleted

  has_many :user_roles, :dependent => :destroy, :foreign_key => 'owner_id', :conditions => {:owner_type => self.to_s}
  has_many :roles, :through => :user_roles, :dependent => :destroy

  has_many :usergroup_members, :dependent => :destroy
  has_many :users,      :through => :usergroup_members, :source => :member, :source_type => 'User', :dependent => :destroy
  has_many :usergroups, :through => :usergroup_members, :source => :member, :source_type => 'Usergroup', :dependent => :destroy
  has_many :external_usergroups, :dependent => :destroy, :inverse_of => :usergroup

  has_many :cached_usergroup_members
  has_many :usergroup_parents, :dependent => :destroy, :foreign_key => 'member_id',
           :conditions => "member_type = 'Usergroup'", :class_name => 'UsergroupMember'
  has_many :parents,    :through => :usergroup_parents, :source => :usergroup, :dependent => :destroy

  has_many_hosts :as => :owner
  validates :name, :uniqueness => true, :presence => true

  # The text item to see in a select dropdown menu
  alias_attribute :select_title, :to_s
  default_scope lambda { order('usergroups.name') }
  scope :visible, lambda { }
  scoped_search :on => :name, :complete_value => :true
  validate :ensure_uniq_name, :ensure_last_admin_remains_admin

  accepts_nested_attributes_for :external_usergroups, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true

  def to_param
    "#{id}-#{name.parameterize}"
  end

  # This methods retrieves all user addresses in a usergroup
  # Returns: Array of strings representing the user's email addresses
  def recipients
    all_users.map(&:mail).flatten.sort.uniq
  end

  def recipients_for(notification)
    all_users.collect { |user| user.mail if user.receives? notification }.compact.sort.uniq
  end

  # This methods retrieves all users in a usergroup
  # Returns: Array of users
  def all_users(group_list = [self], user_list = [])
    retrieve_users_and_groups group_list, user_list
    user_list.sort.uniq
  end

  # This methods retrieves all usergroups in a usergroup
  # Returns: Array of unique usergroups
  def all_usergroups(group_list = [self], user_list = [])
    retrieve_users_and_groups group_list, user_list
    group_list.sort.uniq
  end

  def expire_topbar_cache(sweeper)
    users.each { |u| u.expire_topbar_cache(sweeper) }
  end

  def add_users(userlist)
    users << User.where( {:login => userlist } )
  end

  def remove_users(userlist)
    old_users = User.select { |user| userlist.include?(user.login) }
    self.users = self.users - old_users
  end

  protected
  # Recurses down the tree of usergroups and finds the users
  # [+group_list+]: Array of Usergroups that have already been processed
  # [+users+]     : Array of users accumulated at this point
  # Returns       : Array of non unique users
  def retrieve_users_and_groups(group_list, user_list)
    for group in usergroups
      next if group_list.include? group
      group_list << group

      group.retrieve_users_and_groups(group_list, user_list)
    end
    user_list.concat users
  end

  def ensure_uniq_name
    errors.add :name, _("is already used by a user account") if User.where(:login => name).first
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
      false
    end
  end

  def other_admins
    User.unscoped.only_admin.except_hidden - all_users
  end
end
