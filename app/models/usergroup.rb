class Usergroup < ActiveRecord::Base
  has_many_polymorphs :members, :from => [:usergroups, :users ], :as => :member,
    :through => :usergroup_member, :foreign_key => :usergroup_id, :dependent => :destroy

  has_many :hosts, :as => :owner
  validates_uniqueness_of :name
  before_destroy Ensure_not_used_by.new(:hosts, :usergroups)
  alias_attribute :to_s, :name
  alias_attribute :to_label, :name

  # The text item to see in a select dropdown menu
  alias_method :select_title, :to_s

  # Support for sorting the groups by name
  def <=>(other)
    self.name <=> other.name
  end

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
  # Returns: Array of usergroups
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

  def validate
    if User.all.map(&:login).include?(self.name)
      errors.add :name, "is already used by a user account"
    end
  end

end
