class UserHostgroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :hostgroup

  validates_presence_of :hostgroup_id
  validates_presence_of :user_id

  validates_uniqueness_of :user_id, :scope => :hostgroup_id, :message => "has this hostgroup already"
end

