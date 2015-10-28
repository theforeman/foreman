class TemplateCombination < ActiveRecord::Base
  attr_accessible :environment_id, :hostgroup_id, :hostgroup, :environment

  belongs_to :provisioning_template
  belongs_to :environment
  belongs_to :hostgroup

  validates :environment_id, :uniqueness => {:scope => [:hostgroup_id, :provisioning_template_id]}
  validates :hostgroup_id, :uniqueness => {:scope => [:environment_id, :provisioning_template_id]}
end
