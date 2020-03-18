class UsergroupMember < ApplicationRecord
  # the belongs to would apply default scope limiting the search by taxonomies but we need to delete
  # all members, regardless of their taxonomies
  #
  # we can't use custom scope definition in belongs_to because it's polymorphic, unscope(:where) would reset
  # the member_type condition so we need to override how we search for members
  module OverrideMemberAssociation
    def member
      case member_type
        when 'User'
          User.unscoped { super }
        when 'Usergroup'
          Usergroup.unscoped { super }
        else
          raise ArgumentError, "Unknown member type #{member_type}"
      end
    end
  end

  belongs_to :member, :polymorphic => true
  prepend OverrideMemberAssociation

  belongs_to :usergroup

  before_validation :ensure_no_cycle, :ensure_not_reflexive
  before_update :remove_old_cache_for_old_record
  after_save :add_new_cache
  after_destroy :remove_old_cache

  scope :user_memberships, -> { where("member_type = 'User'") }
  scope :usergroup_memberships, -> { where("member_type = 'Usergroup'") }

  private

  def ensure_not_reflexive
    if member_id == usergroup_id && member_type == 'Usergroup'
      errors.add :base, (_('cannot contain itself as member') % Usergroup.find(usergroup_id).name)
      raise ::Foreman::CyclicGraphException, self
    end
  end

  def ensure_no_cycle
    if member_type != 'User'
      current = UsergroupMember.usergroup_memberships
      EnsureNoCycle.new(current, :usergroup_id, :member_id).ensure(self)
    end
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
    klass = member_type_changed? ? member_type_was.constantize : member_type.constantize
    users = if member_id_changed?
              find_all_affected_users_for(klass.unscoped.find(member_id_was)).flatten
            else
              find_all_affected_users
            end

    roles = if usergroup_id_changed?
              find_all_user_roles_for(Usergroup.unscoped.find(usergroup_id_was)).flatten
            else
              find_all_user_roles
            end

    drop_role_cache(users, roles)

    groups = if usergroup_id_changed?
               find_all_usergroups_for(Usergroup.unscoped.find(usergroup_id_was)).flatten
             else
               find_all_usergroups
             end

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
    memberships = find_all_affected_memberships
    memberships = memberships.reject(&:destroyed?)
    memberships.each(&:save!)
  end

  def drop_role_cache(users, user_roles)
    CachedUserRole.where(:user_role_id => user_roles.map(&:id), :user_id => users.map(&:id)).destroy_all
  end

  def drop_group_cache(users, groups)
    CachedUsergroupMember.where(:user_id => users.map(&:id), :usergroup_id => groups.map(&:id)).destroy_all
  end

  def find_all_affected_users
    find_all_affected_users_for(member_type.constantize.unscoped.find(member_id)).flatten.uniq
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
      find_all_affected_memberships_for(usergroup, :parents),
    ].flatten
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
    (UserRole.where(:owner => usergroup) + usergroup.parents.map { |g| find_all_user_roles_for(g) }).flatten
  end

  def find_all_usergroups
    find_all_usergroups_for(usergroup).flatten
  end

  def find_all_usergroups_for(usergroup)
    [usergroup] + usergroup.parents.map { |p| find_all_usergroups_for(p) }
  end
end
