class Hostgroup < ApplicationRecord
  include Authorizable
  extend FriendlyId
  friendly_id :title
  include Taxonomix
  include HostCommon

  include NestedAncestryCommon
  include NestedAncestryCommon::Search

  validates :name, :presence => true, :uniqueness => {:scope => :ancestry, :case_sensitive => false}

  validate :validate_subnet_types

  include ScopedSearchExtensions
  include SelectiveClone

  validates_lengths_from_database :except => [:name]
  before_destroy EnsureNotUsedBy.new(:hosts)
  has_many :hostgroup_classes
  has_many :puppetclasses, :through => :hostgroup_classes, :dependent => :destroy
  validates :root_pass, :allow_blank => true, :length => {:minimum => 8, :message => _('should be 8 characters or more')}
  has_many :group_parameters, :dependent => :destroy, :foreign_key => :reference_id, :inverse_of => :hostgroup
  accepts_nested_attributes_for :group_parameters, :allow_destroy => true
  include ParameterValidators
  include PxeLoaderValidator
  include PxeLoaderSuggestion
  alias_attribute :hostgroup_parameters, :group_parameters
  has_many_hosts
  has_many :template_combinations, :dependent => :destroy
  has_many :provisioning_templates, :through => :template_combinations

  belongs_to :domain
  belongs_to :subnet
  belongs_to :subnet6, :class_name => "Subnet"

  before_save :remove_duplicated_nested_class

  alias_attribute :arch, :architecture
  alias_attribute :os, :operatingsystem
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"

  nested_attribute_for :compute_profile_id, :environment_id, :domain_id, :puppet_proxy_id, :puppet_ca_proxy_id, :compute_resource_id,
                       :operatingsystem_id, :architecture_id, :medium_id, :ptable_id, :subnet_id, :subnet6_id, :realm_id, :pxe_loader

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("hostgroups.title")
    end
  }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :relation => :group_parameters,    :on => :value, :on_key=> :name, :complete_value => true, :only_explicit => true, :rename => :params
  scoped_search :relation => :hosts, :on => :name, :complete_value => :true, :rename => "host", :only_explicit => true
  scoped_search :relation => :puppetclasses, :on => :name, :complete_value => true, :rename => :class, :only_explicit => true, :operators => ['= ', '~ ']
  scoped_search :relation => :environment, :on => :name, :complete_value => :true, :rename => :environment, :only_explicit => true
  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  # for legacy purposes, keep search on :label
  scoped_search :on => :title, :complete_value => true, :rename => :label
  scoped_search :relation => :config_groups, :on => :name, :complete_value => true, :rename => :config_group, :only_explicit => true, :operators => ['= ', '~ '], :ext_method => :search_by_config_group

  def self.search_by_config_group(key, operator, value)
    conditions = sanitize_sql_for_conditions(["config_groups.name #{operator} ?", value_to_sql(operator, value)])
    hostgroup_ids = Hostgroup.unscoped.with_taxonomy_scope.joins(:config_groups).where(conditions).map(&:subtree_ids).flatten.uniq

    opts = 'hostgroups.id < 0'
    opts = "hostgroups.id IN(#{hostgroup_ids.join(',')})" unless hostgroup_ids.blank?
    {:conditions => opts}
  end

  if SETTINGS[:unattended]
    scoped_search :relation => :architecture,     :on => :name,        :complete_value => true,  :rename => :architecture, :only_explicit => true
    scoped_search :relation => :operatingsystem,  :on => :name,        :complete_value => true,  :rename => :os, :only_explicit => true
    scoped_search :relation => :operatingsystem,  :on => :description, :complete_value => true,  :rename => :os_description, :only_explicit => true
    scoped_search :relation => :operatingsystem,  :on => :title,       :complete_value => true,  :rename => :os_title, :only_explicit => true
    scoped_search :relation => :operatingsystem,  :on => :major,       :complete_value => true,  :rename => :os_major, :only_explicit => true
    scoped_search :relation => :operatingsystem,  :on => :minor,       :complete_value => true,  :rename => :os_minor, :only_explicit => true
    scoped_search :relation => :operatingsystem,  :on => :id,          :complete_enabled => false, :rename => :os_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :relation => :medium,           :on => :name,        :complete_value => true, :rename => "medium", :only_explicit => true
    scoped_search :relation => :provisioning_templates, :on => :name,  :complete_value => true, :rename => "template", :only_explicit => true
  end

  # returns reports for hosts in the User's filter set
  scope :my_groups, lambda {
    user = User.current
    unless user.admin?
      conditions = sanitize_sql_for_conditions([" (hostgroups.id in (?))", user.hostgroup_ids])
      conditions.sub!(/\s*\(\)\s*/, "")
      conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
      conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
    end
    where(conditions)
  }

  class Jail < Safemode::Jail
    allow :name, :diskLayout, :puppetmaster, :operatingsystem, :architecture,
      :environment, :ptable, :url_for_boot, :params, :puppetproxy,
      :puppet_ca_server, :indent, :os, :arch, :domain, :subnet,
      :subnet6, :realm, :root_pass, :description, :pxe_loader
  end

  #TODO: add a method that returns the valid os for a hostgroup

  def hostgroup
    self
  end

  def diskLayout
    ptable.layout.tr("\r", '')
  end

  def all_config_groups
    (config_groups + parent_config_groups).uniq
  end

  def parent_config_groups
    return [] unless parent
    groups = []
    ancestors.each do |hostgroup|
      groups += hostgroup.config_groups
    end
    groups.uniq
  end

  # the environment used by #clases nees to be self.environment and not self.parent.environment
  def parent_classes
    return [] unless parent
    parent.classes(self.environment)
  end

  def inherited_lookup_value(key)
    ancestors.reverse_each do |hg|
      if (v = LookupValue.where(:lookup_key_id => key.id, :id => hg.lookup_values).first)
        return v.value, hg.to_label
      end
    end if key.path_elements.flatten.include?("hostgroup") && Setting["host_group_matchers_inheritance"]
    [key.default_value, _("Default value")]
  end

  def parent_params(include_source = false)
    hash = {}
    ids = ancestor_ids
    # need to pull out the hostgroups to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    groups = Hostgroup.sort_by_ancestry(Hostgroup.includes(:group_parameters).find(ids))
    groups.each do |hg|
      hg.group_parameters.authorized(:view_params).each {|p| hash[p.name] = include_source ? {:value => p.value, :source => p.associated_type, :safe_value => p.safe_value, :source_name => hg.title} : p.value }
    end
    hash
  end

  # returns self and parent parameters as a hash
  def parameters(include_source = false)
    hash = parent_params(include_source)
    group_parameters.each {|p| hash[p.name] = include_source ? {:value => p.value, :source => p.associated_type, :safe_value => p.safe_value, :source_name => title} : p.value }
    hash
  end

  def global_parameters
    Hostgroup.sort_by_ancestry(Hostgroup.includes(:group_parameters).find(ancestor_ids + id)).map(&:group_parameters).uniq
  end

  def params
    parameters = {}
    # read common parameters
    CommonParameter.where(nil).find_each {|p| parameters.update Hash[p.name => p.value] }
    # read OS parameters
    operatingsystem.os_parameters.each {|p| parameters.update Hash[p.name => p.value] } if operatingsystem
    # read group parameters only if a host belongs to a group
    parameters.update self.parameters if hostgroup
    parameters
  end

  # no need to store anything in the db if the password is our default
  def root_pass
    return read_attribute(:root_pass) if read_attribute(:root_pass).present?
    npw = nested_root_pw
    return npw if npw.present?
    Setting[:root_pass]
  end

  def explicit_pxe_loader
    read_attribute(:pxe_loader).presence
  end

  def pxe_loader
    explicit_pxe_loader || nested(:pxe_loader).presence
  end

  include_in_clone :lookup_values, :hostgroup_classes, :locations, :organizations, :group_parameters
  exclude_from_clone :name, :title, :lookup_value_matcher

  # Clone the hostgroup
  def clone(name = "")
    new = self.selective_clone
    new.name = name
    new.title = name
    new.lookup_values.each do |lv|
      lv.match = new.lookup_value_match
      lv.host_or_hostgroup = new
    end

    new.config_groups = self.config_groups
    new
  end

  def hosts_count
    Host::Managed.authorized(:view_hosts, Host).where(:hostgroup => id).size
  end

  def children_hosts_count
    Host::Managed.authorized.where(:hostgroup => subtree_ids).size
  end

  # rebuilds orchestration configuration for hostgroup's hosts
  # takes all the methods from Orchestration modules that are registered for configuration rebuild
  # arguments:
  # => only : Array of rebuild methods to execute (Example: ['TFTP'])
  # => children_hosts : Boolean that if true will operate on children hostgroup's hosts
  # returns  : Hash with 'true' if rebuild was a success for a given key (Example: {'host.example.com': {"TFTP" => true, "DNS" => false}})
  def recreate_hosts_config(only = nil, children_hosts = false)
    result = {}

    Host::Managed.authorized.where(:hostgroup => (children_hosts ? subtree_ids : self.id)).find_each do |host|
      result[host.name] = host.recreate_config(only)
    end
    result
  end

  protected

  def lookup_value_match
    "hostgroup=#{to_label}"
  end

  private

  def nested_root_pw
    Hostgroup.sort_by_ancestry(ancestors).reverse_each do |a|
      return a.root_pass unless a.root_pass.blank?
    end if ancestry.present?
    nil
  end

  def remove_duplicated_nested_class
    self.puppetclasses -= ancestors.map(&:puppetclasses).flatten
  end

  # overwrite method in taxonomix, since hostgroup has ancestry
  def used_taxonomy_ids(type)
    return [] if new_record? && parent_id.blank?
    Host::Base.where(:hostgroup_id => self.path_ids).distinct.pluck(type).compact
  end

  def password_base64_encrypted?
    !root_pass_changed?
  end

  def validate_subnet_types
    errors.add(:subnet, _("must be of type Subnet::Ipv4.")) if self.subnet.present? && self.subnet.type != 'Subnet::Ipv4'
    errors.add(:subnet6, _("must be of type Subnet::Ipv6.")) if self.subnet6.present? && self.subnet6.type != 'Subnet::Ipv6'
  end
end
