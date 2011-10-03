class Hostgroup < ActiveRecord::Base
  has_ancestry :orphan_strategy => :rootify
  include Authorization
  include HostCommon
  include Vm
  has_and_belongs_to_many :puppetclasses
  has_and_belongs_to_many :users, :join_table => "user_hostgroups"
  validates_uniqueness_of :name, :scope => :ancestry, :case_sensitive => false
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white spaces."
  has_many :group_parameters, :dependent => :destroy, :foreign_key => :reference_id
  accepts_nested_attributes_for :group_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  has_many :hosts
  before_destroy Ensure_not_used_by.new(:hosts)
  has_many :config_templates, :through => :template_combinations
  has_many :template_combinations
  before_save :serialize_vm_attributes

  default_scope :order => 'LOWER(hostgroups.name)'

  alias_attribute :os, :operatingsystem
  alias_attribute :label, :to_label
  acts_as_audited

  scoped_search :on => :name, :complete_value => :true
  scoped_search :in => :group_parameters,    :on => :value, :on_key=> :name, :complete_value => true, :only_explicit => true, :rename => :params
  scoped_search :in => :hosts, :on => :name, :complete_value => :true, :rename => "host"
  scoped_search :in => :puppetclasses, :on => :name, :complete_value => true, :rename => :class, :operators => ['= ', '~ ']
  scoped_search :in => :environment, :on => :name, :complete_value => :true, :rename => :environment
  if SETTINGS[:unattended]
    scoped_search :in => :architecture, :on => :name, :complete_value => :true, :rename => :architecture
    scoped_search :in => :operatingsystem, :on => :name, :complete_value => true, :rename => :os
    scoped_search :in => :medium,            :on => :name, :complete_value => :true, :rename => "medium"
    scoped_search :in => :config_templates, :on => :name, :complete_value => :true, :rename => "template"
  end

  class Jail < Safemode::Jail
    allow :name, :diskLayout, :puppetmaster, :operatingsystem, :architecture,
      :environment, :ptable, :url_for_boot, :params, :puppetproxy
  end

  #TODO: add a method that returns the valid os for a hostgroup

  def all_puppetclasses
    classes
  end

  def to_label
    return unless name
    return name if ancestry.empty?
    ancestors.map{|a| a.name + "/"}.join + name
  end

  def to_param
    "#{id}-#{to_label.parameterize}"
  end

  def as_json(options={})
    super({:only => [:name, :subnet_id, :operatingsystem_id, :domain_id, :id], :methods => [:label, :classes, :parameters].concat(Vm::PROPERTIES), :include => [:environment]}.merge(options))
  end

  def hostgroup
    self
  end

  def diskLayout
    ptable.layout
  end

  def classes
    klasses = []
    ids = ancestor_ids
    ids << id unless new_record? or self.frozen?
    Hostgroup.sort_by_ancestry(Hostgroup.find(ids, :include => :puppetclasses)).each do |hg|
      klasses << hg.puppetclasses
    end
    klasses.flatten.sort
  end

  # returns self and parent parameters as a hash
  def parameters
    hash = {}
    ids = ancestor_ids
    ids << id unless new_record? or self.frozen?
    Hostgroup.sort_by_ancestry(Hostgroup.find(ids, :include => :group_parameters)).each do |hg|
      hg.group_parameters.each {|p| hash[p.name] = p.value }
    end
    hash
  end

  def params
    parameters = {}
    # read common parameters
    CommonParameter.all.each {|p| parameters.update Hash[p.name => p.value] }
    # read OS parameters
    operatingsystem.os_parameters.each {|p| parameters.update Hash[p.name => p.value] } unless operatingsystem.nil?
    # read group parameters only if a host belongs to a group
    parameters.update self.parameters unless hostgroup.nil?
    parameters
  end

  def vm_defaults
    YAML.load(read_attribute(:vm_defaults))
  rescue
    {}
  end

  def vm_defaults=(v={})
    raise "defaults must be a hash" unless v.is_a?(Hash)
    v.delete_if{|attr, value| not Vm::PROPERTIES.include?(attr.to_sym)}
    write_attribute :vm_defaults, v.to_yaml
  end

  def after_find
    deserialize_vm_attributes
  end

  private

  def serialize_vm_attributes
    hash = {}
    Vm::PROPERTIES.each do |attr|
      value = self.send(attr)
      hash[attr.to_s] = value if value
    end
    self.vm_defaults = hash
  end

  def deserialize_vm_attributes
    hash = vm_defaults
    Vm::PROPERTIES.each do |attr|
      eval("@#{attr} = hash[attr.to_s]") if hash.has_key?(attr.to_s)
    end
  end

end
