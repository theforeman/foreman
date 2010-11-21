class TemplateKind < ActiveRecord::Base
  has_many :config_templates
  has_many :os_default_templates
  validates_presence_of :name
  validates_uniqueness_of :name
end
