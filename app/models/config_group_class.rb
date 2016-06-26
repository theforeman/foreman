class ConfigGroupClass < ActiveRecord::Base
  include Authorizable

  audited :associated_with => :config_group, :allow_mass_assignment => true
  attr_accessible :config_group_id, :puppetclass_id

  belongs_to :puppetclass
  belongs_to :config_group

  validates :puppetclass, :presence => true
  validates :config_group, :presence => true,
    :uniqueness => { :scope => :puppetclass_id }
end
