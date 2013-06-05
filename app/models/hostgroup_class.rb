class HostgroupClass < ActiveRecord::Base
  include Authorization
  audited :associated_with => :hostgroup, :allow_mass_assignment => true
  belongs_to :hostgroup
  belongs_to :puppetclass

  attr_accessible :hostgroup_id, :hostgroup, :puppetclass_id, :puppetclass
  validates_presence_of :hostgroup_id, :puppetclass_id
  validates :puppetclass_id, :uniqueness => {:scope => :hostgroup_id}

  def name
    "#{hostgroup} - #{puppetclass}"
  end

end
