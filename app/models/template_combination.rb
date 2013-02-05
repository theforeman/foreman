class TemplateCombination < ActiveRecord::Base
  belongs_to :config_template
  belongs_to :environment
  belongs_to :hostgroup
  validates_uniqueness_of :environment_id, :scope => [:hostgroup_id, :config_template_id]
  validates_uniqueness_of :hostgroup_id, :scope => [:environment_id, :config_template_id]

  # process_resource_error relies on presence of this method
  def permission_failed?
    false
  end
end
