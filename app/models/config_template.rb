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

  def self.find_template opts = {}
    raise "Must provide template kind"        unless opts[:kind]
    raise "Must provide an operating systems" unless opts[:operatingsystem_id]

    # first filter valid templates to our OS and requested template kind.
    templates = ConfigTemplate.operatingsystems_id_eq(opts[:operatingsystem_id]).template_kind_name_eq(opts[:kind])

    # once a template has been matched, we no longer look for others.

    if opts[:hostgroup_id] and opts[:environment_id]
      # try to find a full match to our host group and environment
      template = templates.hostgroups_id_eq(opts[:hostgroup_id]).environments_id_eq(opts[:environment_id]).first
    end

    if opts[:hostgroup_id]
      # try to find a match with our hostgroup only
      template ||= templates.hostgroups_id_eq(opts[:hostgroup_id]).first
    end

    if opts[:environment_id]
      # search for a template based only on our environment
      template ||= templates.environments_id_eq(opts[:environment_id]).first
    end

    # fall back to the os default template
    template ||= templates.os_default_templates_operatingsystem_id_eq(opts[:operatingsystem_id]).first
    template.is_a?(ConfigTemplate) ? template : nil
  end

  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?

    return true if User.current and User.current.allowed_to?("#{operation}_templates".to_sym)

    errors.add_to_base "You do not have permission to #{operation} this template"
    false
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
    super({:only => [:name, :template, :id, :snippet],:include => [:template_kind]}.merge(options))
  end

end
