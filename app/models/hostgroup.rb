class Hostgroup < ActiveRecord::Base
  has_ancestry :orphan_strategy => :rootify
  include Authorization
  include HostCommon
  include Vm
  has_many :hostgroup_classes, :dependent => :destroy
  has_many :puppetclasses, :through => :hostgroup_classes
  has_and_belongs_to_many :users, :join_table => "user_hostgroups"
  validates_uniqueness_of :name, :scope => :ancestry, :case_sensitive => false
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white spaces."
  has_many :group_parameters, :dependent => :destroy, :foreign_key => :reference_id
  accepts_nested_attributes_for :group_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  has_many :hosts
  before_destroy EnsureNotUsedBy.new(:hosts)
  has_many :config_templates, :through => :template_combinations
  has_many :template_combinations
  before_save :serialize_vm_attributes
  before_save :remove_duplicated_nested_class
  after_find :deserialize_vm_attributes

  alias_attribute :os, :operatingsystem
  alias_attribute :label, :to_label
  audited
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"

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

  # returns reports for hosts in the User's filter set
  scope :my_groups, lambda {
    user = User.current
    if user.admin?
      conditions = { }
    else
      conditions = sanitize_sql_for_conditions([" (hostgroups.id in (?))", user.hostgroups.map(&:id)])
      conditions.sub!(/\s*\(\)\s*/, "")
      conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
      conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
    end
    {:conditions => conditions}
  }

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
    super({:only => [:name, :subnet_id, :operatingsystem_id, :domain_id, :environment_id, :id, :ancestry], :methods => [:label, :parameters, :puppetclass_ids].concat(Vm::PROPERTIES)})
  end

  def hostgroup
    self
  end

  def diskLayout
    ptable.layout
  end

  def classes
    Puppetclass.joins(:hostgroups).where(:hostgroups => {:id => path_ids})
  end

  def puppetclass_ids
    classes.reorder('').pluck(:id)
  end

  # returns self and parent parameters as a hash
  def parameters include_source = false
    hash = {}
    ids = ancestor_ids
    ids << id unless new_record? or self.frozen?
    # need to pull out the hostgroups to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    groups = ids.size == 1 ? [self] : Hostgroup.sort_by_ancestry(Hostgroup.find(ids, :include => :group_parameters))
    groups.each do |hg|
      hg.group_parameters.each {|p| hash[p.name] = include_source ? {:value => p.value, :source => :hostgroup} : p.value }
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

  # no need to store anything in the db if the password is our default
  def root_pass
    read_attribute(:root_pass) || nested_root_pw
  end

  private

  def nested_root_pw
    Hostgroup.sort_by_ancestry(ancestors).reverse.each do |a|
      return a.root_pass unless a.root_pass.blank?
    end if ancestry.present?
    nil
  end

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

  def remove_duplicated_nested_class
    self.puppetclasses -= ancestors.map(&:puppetclasses).flatten
  end

end
