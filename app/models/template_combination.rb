class TemplateCombination < ActiveRecord::Base
  include Authorization

  belongs_to :config_template
  belongs_to :environment
  belongs_to :hostgroup
  validates_uniqueness_of :environment_id, :scope => [:hostgroup_id, :config_template_id]
  validates_uniqueness_of :hostgroup_id, :scope => [:environment_id, :config_template_id]
end
