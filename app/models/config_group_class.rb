class ConfigGroupClass < ActiveRecord::Base
  include Authorizable
  include CounterCacheFix
  include PuppetclassTotalHosts::JoinTable

  audited :associated_with => :config_group, :allow_mass_assignment => true

  belongs_to :puppetclass
  belongs_to :config_group, :counter_cache => true

  validates :puppetclass, :presence => true
  validates :config_group, :presence => true,
                              :uniqueness => {:scope => :puppetclass}
end
