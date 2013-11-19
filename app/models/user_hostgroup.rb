class UserSystemGroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :system_group

  validates :system_group_id, :presence => true
  validates :user_id, :presence => true, :uniqueness => {:scope => :system_group_id, :message => N_("has this system_group already")}

end

