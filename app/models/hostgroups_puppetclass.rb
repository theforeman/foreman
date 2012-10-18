class HostgroupsPuppetclass < ActiveRecord::Base

  belongs_to :hostgroup
  belongs_to :puppetclass

  validates_presence_of :hostgroup_id, :puppetclass_id

  audited :associated_with => :hostgroup

  def name
    "#{hostgroup} - #{puppetclass}"
  end
end
