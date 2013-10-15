class UserHostgroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :hostgroup

  validates :hostgroup_id, :presence => true
  validates :user_id, :presence => true, :uniqueness => {:scope => :hostgroup_id, :message => N_("has this hostgroup already")}

end

