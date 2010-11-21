class Hostgroup < ActiveRecord::Base
  include Authorization
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

  acts_as_audited

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
end
