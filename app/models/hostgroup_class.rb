class HostgroupClass < ActiveRecord::Base
  include Authorizable
  include CounterCacheFix
  include PuppetclassTotalHosts::JoinTable

  audited :associated_with => :hostgroup, :allow_mass_assignment => true
  belongs_to :hostgroup
  belongs_to :puppetclass, :counter_cache => :hostgroups_count

  #disabled because when created with hostgroup, fails validation
  #TODO: find a way to fix this
  #validates :hostgroup_id, :presence => true
  validates :puppetclass_id, :presence => true, :uniqueness => {:scope => :hostgroup_id}

  def name
    "#{hostgroup} - #{puppetclass}"
  end
end
