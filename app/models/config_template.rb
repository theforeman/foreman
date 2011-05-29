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
  accepts_nested_attributes_for :template_combinations, :allow_destroy => true, :reject_if => lambda {|tc| tc[:environment_id].blank? and tc[:hostgroup_id].blank? }
  has_and_belongs_to_many :operatingsystems
  has_many :os_default_templates
  before_save :check_for_snippet_assoications, :remove_trailing_chars
  default_scope :order => 'LOWER(config_templates.name)'

  scoped_search :on => :name,    :complete_value => true, :default_order => true
  scoped_search :on => :snippet, :complete_value => true, :complete_value => {:true => true, :false => false}
  scoped_search :on => :template

  scoped_search :in => :operatingsystems, :on => :name, :rename => :operatingsystem, :complete_value => true
  scoped_search :in => :environments,     :on => :name, :rename => :environment,     :complete_value => true
  scoped_search :in => :hostgroups,       :on => :name, :rename => :hostgroup,       :complete_value => true
  scoped_search :in => :template_kind,    :on => :name, :rename => :kind,            :complete_value => true

  class Jail < Safemode::Jail
    allow :name
  end

  def to_param
    name
  end

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

  def remove_trailing_chars
    self.template.gsub!("\r","") unless template.empty?
  end

  def as_json(options={})
    super({:only => [:name, :template, :snippet]}.merge(options))
  end

end
