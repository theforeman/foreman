class UsergroupMember < ActiveRecord::Base
  belongs_to :member, :polymorphic => true
  belongs_to :usergroup

end
