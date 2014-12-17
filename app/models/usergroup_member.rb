class UsergroupMember < ActiveRecord::Base
  belongs_to :member, :polymorphic => true
  belongs_to :usergroup

  before_validation :ensure_no_cycle
  before_update :remove_old_cache_for_old_record
  after_save :add_new_cache
  after_destroy :remove_old_cache

  scope :user_memberships, lambda { where("member_type = 'User'") }
  scope :usergroup_memberships, lambda { where("member_type = 'Usergroup'") }

  private

  def ensure_no_cycle
    current = UsergroupMember.usergroup_memberships
    EnsureNoCycle.new(current, :usergroup_id, :member_id).ensure(self)
  end

  def add_new_cache
    find_all_affected_users.each do |user|
      find_all_user_roles.each do |user_role|
        CachedUserRole.create!(:user      => user, :role => user_role.role,
                               :user_role => user_role)
      end

      find_all_usergroups.each do |group|
        CachedUsergroupMember.create!(:user => user, :usergroup => group)
      end
    end
  end

  def remove_old_cache_for_old_record
    klass = member_type_changed? ? self.member_type_was.constantize : self.member_type.constantize
    users = member_id_changed? ? find_all_affected_users_for(klass.find(member_id_was)).flatten : find_all_affected_users
    roles = usergroup_id_changed? ? find_all_user_roles_for(Usergroup.find(usergroup_id_was)).flatten : find_all_user_roles

    drop_role_cache(users, roles)

    groups = usergroup_id_changed? ? find_all_usergroups_for(Usergroup.find(usergroup_id_was)).flatten : find_all_usergroups
    drop_group_cache(users, groups)
  end

  def remove_old_cache
    users = find_all_affected_users
    drop_role_cache(users, find_all_user_roles)
    drop_group_cache(users, find_all_usergroups)

    # we need to recache records that may got deleted unintentionally
    # we can't detect exact records to delete since we'd have to distinguish by whole path
    recache_memberships
  end

  def recache_memberships
    find_all_affected_memberships.each(&:save!)
  end

  def drop_role_cache(users, user_roles)
    CachedUserRole.where(:user_role_id => user_roles.map(&:id), :user_id => users.map(&:id)).destroy_all
  end

  def drop_group_cache(users, groups)
    CachedUsergroupMember.where(:user_id => users.map(&:id), :usergroup_id => groups.map(&:id)).destroy_all
  end

  def find_all_affected_users
    find_all_affected_users_for(member).flatten.uniq
  end

  def find_all_affected_users_for(member)
    if member.is_a?(User)
      [member]
    elsif member.is_a?(Usergroup)
      [member.users + member.usergroups.map { |g| find_all_affected_users_for(g) }]
    else
      raise ArgumentError, "Unknown member type #{member}"
    end
  end

  def find_all_affected_memberships
    [
      find_all_affected_memberships_for(member, :usergroups),
      find_all_affected_memberships_for(usergroup, :parents)
    ].flatten
  end

  def find_all_affected_memberships_for(member, direction = :usergroups)
    if member.is_a?(User)
      [ member.usergroup_member ]
    elsif member.is_a?(Usergroup)
      [ member.usergroup_members.user_memberships +
           member.send(direction).map { |g| find_all_affected_memberships_for(g, direction) } ]
    else
      raise ArgumentError, "Unknown member type #{member}"
    end
  end

  def find_all_user_roles
    find_all_user_roles_for(usergroup).flatten
  end

  def find_all_user_roles_for(usergroup)
    (UserRole.where(owner: usergroup) + usergroup.parents.map { |g| find_all_user_roles_for(g) }).flatten
  end

  def find_all_usergroups
    find_all_usergroups_for(usergroup).flatten
  end

  def find_all_usergroups_for(usergroup)
    [ usergroup ] + usergroup.parents.map { |p| find_all_usergroups_for(p) }
  end
end
