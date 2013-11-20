class CachedUserRole < ActiveRecord::Base
  attr_accessible :role_id, :user_id, :user_role_id, :role, :user, :user_role

  belongs_to :user
  belongs_to :role

  # this UserRole created this cache
  belongs_to :user_role
end
