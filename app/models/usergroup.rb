class Usergroup < ActiveRecord::Base
  include Authorization
  audited :allow_mass_assignment => true

  has_many :user_roles, :dependent => :destroy, :foreign_key => 'owner_id', :conditions => {:owner_type => self.to_s}
  has_many :roles, :through => :user_roles, :dependent => :destroy

  has_many :usergroup_members, :dependent => :destroy
  has_many :users,      :through => :usergroup_members, :source => :member, :source_type => 'User', :dependent => :destroy
  has_many :usergroups, :through => :usergroup_members, :source => :member, :source_type => 'Usergroup', :dependent => :destroy

  has_many :cached_usergroup_members
  has_many :usergroup_parents, :dependent => :destroy, :foreign_key => 'member_id',
           :conditions => "member_type = 'Usergroup'", :class_name => 'UsergroupMember'
  has_many :parents,    :through => :usergroup_parents, :source => :usergroup, :dependent => :destroy


  has_many_hosts :as => :owner
  validates :name, :uniqueness => true
  before_destroy EnsureNotUsedBy.new(:hosts, :usergroups)

  # The text item to see in a select dropdown menu
  alias_attribute :select_title, :to_s
  default_scope lambda { order('usergroups.name') }
  scoped_search :on => :name, :complete_value => :true
  validate :ensure_uniq_name

  # This methods retrieves all user addresses in a usergroup
  # Returns: Array of strings representing the user's email addresses
  def recipients
    all_users.map(&:mail).flatten.sort.uniq
  end

  # This methods retrieves all users in a usergroup
  # Returns: Array of users
  def all_users(group_list=[self], user_list=[])
    retrieve_users_and_groups group_list, user_list
    user_list.sort.uniq
  end

  # This methods retrieves all usergroups in a usergroup
  # Returns: Array of unique usergroups
  def all_usergroups(group_list=[self], user_list=[])
    retrieve_users_and_groups group_list, user_list
    group_list.sort.uniq
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

end
