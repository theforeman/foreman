class CachedUserRole < ActiveRecord::Base
  attr_accessible :role_id, :user_id, :user_role_id, :role, :user, :user_role, :user_membership

  belongs_to :user
  belongs_to :role

  # this UserRole created this cache
  belongs_to :user_role
  # this UsergroupMember created this cache (User membership)
  belongs_to :user_membership, :class_name => UsergroupMember
end
