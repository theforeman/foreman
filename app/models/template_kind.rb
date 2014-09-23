class TemplateKind < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  validates_lengths_from_database
  has_many :config_templates, :inverse_of => :template_kind
  has_many :os_default_templates
  validates :name, :presence => true, :uniqueness => true
  scoped_search :on => :name
end
