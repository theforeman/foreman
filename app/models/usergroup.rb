require 'user'
class Usergroup < ActiveRecord::Base
  include Authorization
  has_many_polymorphs :members, :from => [:usergroups, :users ], :as => :member,
    :through => :usergroup_member, :foreign_key => :usergroup_id, :dependent => :destroy

  has_many :hosts, :as => :owner
  validates_uniqueness_of :name
  before_destroy EnsureNotUsedBy.new(:hosts, :usergroups)

  # The text item to see in a select dropdown menu
  alias_attribute :select_title, :to_s
  default_scope :order => 'LOWER(usergroups.name)'
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

  def as_json(options={})
    super({:only => [:name, :id]})
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
    errors.add :name, "is already used by a user account" if User.where(:login => name).first
  end

end
