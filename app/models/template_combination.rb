class TemplateCombination < ActiveRecord::Base
  belongs_to :config_template
  belongs_to :environment
  belongs_to :hostgroup
  validates :environment_id, :uniqueness => {:scope => [:hostgroup_id, :config_template_id]}
  validates :hostgroup_id, :uniqueness => {:scope => [:environment_id, :config_template_id]}

end
