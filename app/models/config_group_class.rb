class ConfigGroupClass < ActiveRecord::Base
  include Authorizable
  audited :associated_with => :config_group, :allow_mass_assignment => true
  attr_accessible :config_group_id, :puppetclass_id

  belongs_to :puppetclass
  belongs_to :config_group, :counter_cache => true

  validates :puppetclass_id, :presence => true
  validates :config_group_id, :presence => true,
                              :uniqueness => {:scope => :puppetclass_id}

end
