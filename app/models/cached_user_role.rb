class CachedUserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role

  # this UserRole created this cache
  belongs_to :user_role
end
