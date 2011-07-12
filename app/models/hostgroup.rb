class Hostgroup < ActiveRecord::Base
  has_ancestry :orphan_strategy => :rootify
  include Authorization
  include HostCommon
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
  belongs_to :operatingsystem
  belongs_to :environment
  belongs_to :architecture
  belongs_to :medium
  belongs_to :ptable
  belongs_to :puppetproxy, :class_name => "SmartProxy"

  default_scope :order => 'LOWER(hostgroups.name)'

  alias_attribute :os, :operatingsystem
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
      :environment, :ptable, :hostgroup, :url_for_boot, :params, :hostgroup, :domain
  end

  #TODO: add a method that returns the valid os for a hostgroup

  def all_puppetclasses
    classes
  end

  alias_method :to_label, :to_s

  def to_label
    return unless name
    ancestors.map{|a| a.name + "/"}.join + name
  end

  def as_json(options={})
    super({:only => [:name, :id], :methods => [:classes, :parameters], :include => [:puppetclasses, :group_parameters, :environment]}.merge(options))
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
    klasses.flatten
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

end
