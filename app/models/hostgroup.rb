class Hostgroup < ActiveRecord::Base
  has_ancestry :orphan_strategy => :rootify
  include Authorization
  include Taxonomix
  include HostCommon
  has_many :hostgroup_classes, :dependent => :destroy
  has_many :puppetclasses, :through => :hostgroup_classes
  has_many :user_hostgroups, :dependent => :destroy
  has_many :users, :through => :user_hostgroups
  validates_uniqueness_of :name, :scope => :ancestry, :case_sensitive => false
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white spaces."
  has_many :group_parameters, :dependent => :destroy, :foreign_key => :reference_id
  accepts_nested_attributes_for :group_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  has_many_hosts
  before_destroy EnsureNotUsedBy.new(:hosts)
  has_many :config_templates, :through => :template_combinations
  has_many :template_combinations
  before_save :remove_duplicated_nested_class
  before_save :set_label, :on => [:create, :update, :destroy]
  after_save :set_other_labels, :on => [:update, :destroy]

  alias_attribute :os, :operatingsystem
  audited
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda { with_taxonomy_scope }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :label, :complete_value => :true
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
      conditions = sanitize_sql_for_conditions([" (hostgroups.id in (?))", user.hostgroup_ids])
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
    return label if label
    get_label
  end

  def to_param
    "#{id}-#{to_label.parameterize}"
  end

  def as_json(options={})
    super({:only => [:name, :subnet_id, :operatingsystem_id, :domain_id, :environment_id, :id, :ancestry], :methods => [:label, :parameters, :puppetclass_ids]})
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

  # no need to store anything in the db if the password is our default
  def root_pass
    read_attribute(:root_pass) || nested_root_pw
  end

  def get_label
    return name if ancestry.empty?
    ancestors.map{|a| a.name + "/"}.join + name
  end

  private

  def set_label
    self.label = get_label if (name_changed? || ancestry_changed?)
  end

  def set_other_labels
    if name_changed? || ancestry_changed?
      Hostgroup.where("ancestry IS NOT NULL").each do |hostgroup|
        if hostgroup.path_ids.include?(self.id)
          hostgroup.update_attributes(:label => hostgroup.get_label)
        end
      end
    end
  end

  def nested_root_pw
    Hostgroup.sort_by_ancestry(ancestors).reverse.each do |a|
      return a.root_pass unless a.root_pass.blank?
    end if ancestry.present?
    nil
  end

  def remove_duplicated_nested_class
    self.puppetclasses -= ancestors.map(&:puppetclasses).flatten
  end

end
