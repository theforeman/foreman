class TemplateKind < ActiveRecord::Base
  has_many :config_templates, :inverse_of => :template_kind
  has_many :os_default_templates
  validates :name, :presence => true, :uniqueness => true
end
