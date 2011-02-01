class Hostgroup < ActiveRecord::Base
  include Authorization
  include HostCommon
  has_and_belongs_to_many :puppetclasses
  has_and_belongs_to_many :users, :join_table => "user_hostgroups"
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white spaces."
  has_many :group_parameters, :dependent => :destroy, :foreign_key => :reference_id
  accepts_nested_attributes_for :group_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  has_many :hosts
  before_destroy Ensure_not_used_by.new(:hosts)
  default_scope :order => 'name'
  has_many :config_templates, :through => :template_combinations, :dependent => :destroy
  has_many :template_combinations
  belongs_to :operatingsystem
  belongs_to :environment
  belongs_to :architecture
  belongs_to :medium
  belongs_to :ptable

  alias_attribute :os, :operatingsystem
  acts_as_audited

  class Jail < Safemode::Jail
    allow :name, :diskLayout, :puppetmaster, :operatingsystem, :environment, :ptable, :hostgroup, :url_for_boot, :params, :hostgroup, :domain
  end

  #TODO: add a method that returns the valid os for a hostgroup

  def all_puppetclasses
    puppetclasses
  end

  def as_json(options={})
    super({:only => [:name, :id]}.merge(options))
  end

  def hostgroup
    self
  end

  def diskLayout
    ptable.layout
  end

  def params
    parameters = {}
    # read common parameters
    CommonParameter.all.each {|p| parameters.update Hash[p.name => p.value] }
    # read OS parameters
    operatingsystem.os_parameters.each {|p| parameters.update Hash[p.name => p.value] } unless operatingsystem.nil?
    # read group parameters only if a host belongs to a group
    hostgroup.group_parameters.each {|p| parameters.update Hash[p.name => p.value] } unless hostgroup.nil?
    parameters
  end

end
