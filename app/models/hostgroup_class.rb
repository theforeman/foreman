class HostgroupClass < ActiveRecord::Base
  include Authorization
  audited :associated_with => :hostgroup
  belongs_to :hostgroup
  belongs_to :puppetclass

  validates_presence_of :hostgroup_id, :puppetclass_id

  def name
    "#{hostgroup} - #{puppetclass}"
  end

end
