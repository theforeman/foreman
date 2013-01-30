class HostgroupClass < ActiveRecord::Base
  audited :associated_with => :hostgroup
  belongs_to :hostgroup
  belongs_to :puppetclass

  attr_accessible :hostgroup_id, :puppetclass_id
  validates_presence_of :hostgroup_id, :puppetclass_id

  def name
    "#{hostgroup} - #{puppetclass}"
  end

end
