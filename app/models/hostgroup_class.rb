class HostgroupClass < ApplicationRecord
  audited :associated_with => :hostgroup
  include Authorizable

  belongs_to :hostgroup
  belongs_to :puppetclass

  validates :hostgroup, :presence => true
  validates :puppetclass_id, :presence => true, :uniqueness => {:scope => :hostgroup_id}

  def name
    "#{hostgroup} - #{puppetclass}"
  end

  def check_permissions_after_save
    true
  end
end
