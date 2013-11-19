class TemplateCombination < ActiveRecord::Base
  belongs_to :config_template
  belongs_to :environment
  belongs_to :system_group
  validates :environment_id, :uniqueness => {:scope => [:system_group_id, :config_template_id]}
  validates :system_group_id, :uniqueness => {:scope => [:environment_id, :config_template_id]}

  # process_resource_error relies on presence of this method
  def permission_failed?
    false
  end
end
