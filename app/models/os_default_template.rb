class OsDefaultTemplate < ActiveRecord::Base
  belongs_to :config_template
  belongs_to :template_kind
  belongs_to :operatingsystem
  validates_presence_of :config_template_id, :template_kind_id
  validates_uniqueness_of :template_kind_id, :scope => :operatingsystem_id

  def name
    "#{operatingsystem} - #{template_kind}"
  end
end