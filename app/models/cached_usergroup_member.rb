class CachedUsergroupMember < ActiveRecord::Base
  include AccessibleAttributes

  belongs_to :user
  belongs_to :usergroup
end
