class HostgroupClass < ActiveRecord::Base
  include Authorizable

  audited :associated_with => :hostgroup
  belongs_to :hostgroup
  belongs_to :puppetclass

  validates :hostgroup, :presence => true
  validates :puppetclass_id, :presence => true, :uniqueness => {:scope => :hostgroup_id}

  def name
    "#{hostgroup} - #{puppetclass}"
  end
end
