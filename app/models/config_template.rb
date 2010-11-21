class ConfigTemplate < ActiveRecord::Base
  include Authorization
  attr_accessible :name, :template, :template_kind_id, :snippet, :template_combinations_attributes, :operatingsystem_ids
  validates_presence_of :name, :template
  validates_presence_of :template_kind_id, :unless => Proc.new {|t| t.snippet }
  validates_uniqueness_of :name
  has_many :hostgroups, :through => :template_combinations
  has_many :environments, :through => :template_combinations
  has_many :template_combinations, :dependent => :destroy
  belongs_to :template_kind
  accepts_nested_attributes_for :template_combinations, :allow_destroy => true
  has_and_belongs_to_many :operatingsystems
  has_many :os_default_templates
  before_save :check_for_snippet_assoications

  private

  # check if our template is a snippet, and remove its associations just in case they were selected.
  def check_for_snippet_assoications
    return unless snippet
    self.hostgroups.clear
    self.environments.clear
    self.template_combinations.clear
    self.operatingsystems.clear
    self.template_kind = nil
  end
end
