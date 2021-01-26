class TemplateCombination < ApplicationRecord
  belongs_to :provisioning_template
  belongs_to :hostgroup

  validates :hostgroup_id, :uniqueness => {:scope => [:provisioning_template_id]}
end
