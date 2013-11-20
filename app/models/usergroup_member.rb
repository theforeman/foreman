class UsergroupMember < ActiveRecord::Base
  belongs_to :member, :polymorphic => true
  belongs_to :usergroup

  after_create :add_new_cache
  before_update :remove_old_cache_for_old_record
  after_update :add_new_cache
  after_destroy :remove_old_cache

  private

  def add_new_cache
    find_all_user_roles.each do |user_role|
      find_all_affected_users.each do |user|
        CachedUserRole.create!(:user => user, :role => user_role.role, :user_role => user_role)
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
  end

  def remove_old_cache
    drop_cache(find_all_affected_users, find_all_user_roles)
  end

  def drop_cache(users, user_roles)
    CachedUserRole.where(:user_role_id => user_roles.map(&:id), :user_id => users.map(&:id)).destroy_all
  end

  def find_all_affected_users
    find_all_affected_users_for(member).flatten
  end

  def find_all_affected_users_for(member)
    if member.is_a?(User)
      [member]
    else
      [member.users + member.usergroups.map { |g| find_all_affected_users_for(g) }]
    end
  end

  def find_all_user_roles
    find_all_user_roles_for(usergroup).flatten
  end

  def find_all_user_roles_for(usergroup)
    usergroup.user_roles + usergroup.parents.map { |g| find_all_user_roles_for(g) }
  end
end
