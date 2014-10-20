class OsDefaultTemplate < ActiveRecord::Base
  belongs_to :config_template
  belongs_to :template_kind
  belongs_to :operatingsystem
  validates :config_template_id, :presence => true
  validates :template_kind_id, :presence => true, :uniqueness => {:scope => :operatingsystem_id}

  default_scope joins(:template_kind).order('template_kinds.name')

  def name
    "#{operatingsystem} - #{template_kind}"
  end
end
