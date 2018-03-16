class ConfigGroupClass < ApplicationRecord
  audited :associated_with => :config_group

  include Authorizable

  belongs_to :puppetclass
  belongs_to :config_group

  validates :puppetclass, :presence => true
  validates :config_group, :presence => true,
    :uniqueness => { :scope => :puppetclass_id }
end
