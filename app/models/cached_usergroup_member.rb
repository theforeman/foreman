class CachedUsergroupMember < ActiveRecord::Base
  attr_accessible :user_id, :usergroup_id, :user, :usergroup

  belongs_to :user
  belongs_to :usergroup

  def self.build_cache!(attributes)
    create!(attributes)
  end
end
