class UsergroupMember < ActiveRecord::Base
  belongs_to :member, :polymorphic => true
  belongs_to :usergroup

  after_create :add_new_cache
  before_update :remove_old_cache_for_old_record
  after_update :add_new_cache
  after_destroy :remove_old_cache
  before_validation :ensure_no_cycle

  scope :user_memberships, lambda { where("member_type = 'User'") }
  scope :usergroup_memberships, lambda { where("member_type = 'Usergroup'") }

  private

  def ensure_no_cycle
    current = UsergroupMember.usergroup_memberships
    EnsureNoCycle.new(current, :usergroup_id, :member_id).ensure(self)
  end


  def add_new_cache
    find_all_user_roles.each do |user_role|
      find_all_affected_users.each do |user|
        CachedUserRole.build_cache!(:user      => user, :role => user_role.role,
                                    :user_role => user_role)
      end
    end

    find_all_usergroups.each do |group|
      find_all_affected_users.each do |user|
        CachedUsergroupMember.build_cache!(:user => user, :usergroup => group)
      end
    end
  end

  def remove_old_cache_for_old_record
    users = nil
    roles = nil
    klass = self.member_type.constantize

    klass = self.member_type_was.constantize if member_type_changed?
    users = find_all_affected_users_for(klass.find(member_id_was)).flatten if member_id_changed?
    roles = find_all_user_roles_for(Usergroup.find(usergroup_id_was)).flatten if usergroup_id_changed?

    drop_cache(users || find_all_affected_users, roles || find_all_user_roles)

    groups = find_all_usergroups_for(Usergroup.find(usergroup_id_was)).flatten if usergroup_id_changed?
    drop_group_cache(users || find_all_affected_users, groups || find_all_usergroups)
  end

  def remove_old_cache
    drop_cache(find_all_affected_users, find_all_user_roles)
    drop_group_cache(find_all_affected_users, find_all_usergroups)

    # we need to recache records that may got deleted unintentionally
    # we can't detect exact records to delete since we'd have to distinguish by whole path
    find_all_affected_memberships.each do |membership|
      membership.save!
    end
  end

  def drop_cache(users, user_roles)
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
    (find_all_affected_memberships_for(member, :usergroups) +
        find_all_affected_memberships_for(usergroup, :parents)).flatten
  end

  def find_all_affected_memberships_for(member, direction = :usergroups)
    if member.is_a?(User)
      [member.usergroup_member]
    elsif member.is_a?(Usergroup)
      [member.usergroup_members.user_memberships +
           member.send(direction).map { |g| find_all_affected_memberships_for(g, direction) }]
    else
      raise ArgumentError, "Unknown member type #{member}"
    end
  end

  def find_all_user_roles
    find_all_user_roles_for(usergroup).flatten
  end

  def find_all_user_roles_for(usergroup)
    usergroup.user_roles + usergroup.parents.map { |g| find_all_user_roles_for(g) }
  end

  def find_all_usergroups
    find_all_usergroups_for(usergroup).flatten
  end

  def find_all_usergroups_for(usergroup)
    [usergroup] + usergroup.parents.map { |p| find_all_usergroups_for(p) }
  end
end
