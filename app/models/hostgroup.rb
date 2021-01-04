class Hostgroup < ApplicationRecord
  audited
  include Authorizable
  extend FriendlyId
  friendly_id :title
  include Taxonomix
  include HostCommon
  include Foreman::ObservableModel

  include NestedAncestryCommon
  include NestedAncestryCommon::Search

  include Facets::HostgroupExtensions

  validates :name, :presence => true, :uniqueness => {:scope => :ancestry, :case_sensitive => false}

  validate :validate_subnet_types
  validates_with SubnetsConsistencyValidator
  validate :validate_compute_profile, :if => proc { |hostgroup| hostgroup.compute_profile_id_changed? && hostgroup.compute_profile_id.present? }

  include ScopedSearchExtensions
  include SelectiveClone

  validates_lengths_from_database :except => [:name]
  before_destroy EnsureNotUsedBy.new(:hosts)
  validates :root_pass, :allow_blank => true, :length => {:minimum => 8, :message => _('should be 8 characters or more')}
  has_many :group_parameters, :dependent => :destroy, :foreign_key => :reference_id, :inverse_of => :hostgroup
  accepts_nested_attributes_for :group_parameters, :allow_destroy => true
  include ParameterValidators
  include ParameterSearch
  include PxeLoaderValidator
  include PxeLoaderSuggestion
  alias_attribute :hostgroup_parameters, :group_parameters
  has_many_hosts
  has_many :template_combinations, :dependent => :destroy
  has_many :provisioning_templates, :through => :template_combinations

  belongs_to :domain
  belongs_to :subnet
  belongs_to :subnet6, :class_name => "Subnet"

  alias_attribute :arch, :architecture
  alias_attribute :os, :operatingsystem

  nested_attribute_for :compute_profile_id, :domain_id, :puppet_proxy_id, :puppet_ca_proxy_id, :compute_resource_id,
    :operatingsystem_id, :architecture_id, :medium_id, :ptable_id, :subnet_id, :subnet6_id, :realm_id, :pxe_loader

  set_crud_hooks :hostgroup

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("hostgroups.title")
    end
  }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :relation => :hosts, :on => :name, :complete_value => :true, :rename => "host", :only_explicit => true
  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  # for legacy purposes, keep search on :label
  scoped_search :on => :title, :complete_value => true, :rename => :label

  scoped_search :relation => :architecture,     :on => :name,        :complete_value => true,  :rename => :architecture, :only_explicit => true
  scoped_search :relation => :operatingsystem,  :on => :name,        :complete_value => true,  :rename => :os, :only_explicit => true
  scoped_search :relation => :operatingsystem,  :on => :description, :complete_value => true,  :rename => :os_description, :only_explicit => true
  scoped_search :relation => :operatingsystem,  :on => :title,       :complete_value => true,  :rename => :os_title, :only_explicit => true
  scoped_search :relation => :operatingsystem,  :on => :major,       :complete_value => true,  :rename => :os_major, :only_explicit => true
  scoped_search :relation => :operatingsystem,  :on => :minor,       :complete_value => true,  :rename => :os_minor, :only_explicit => true
  scoped_search :relation => :operatingsystem,  :on => :id,          :complete_enabled => false, :rename => :os_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :relation => :medium,           :on => :name,        :complete_value => true, :rename => "medium", :only_explicit => true
  scoped_search :relation => :provisioning_templates, :on => :name,  :complete_value => true, :rename => "template", :only_explicit => true

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

  apipie :class, "A class representing #{model_name.human} object" do
    prop_group :basic_model_props, ApplicationRecord, meta: { friendly_name: 'host group' }
    property :architecture, 'Architecture', desc: 'Returns architecture to be used on hosts within this host group'
    property :arch, 'Architecture', desc: 'Returns architecture to be used on hosts within this host group'
    property :description, String, desc: 'Returns description of the host group'
    property :diskLayout, String, desc: 'Returns partition table template to be used on hosts within this host group'
    property :operatingsystem, 'Operatingsystem', desc: 'Returns operating system to be used on hosts within this host group'
    property :os, 'Operatingsystem', desc: 'Returns operating system to be used on hosts within this host group'
    property :ptable, 'Ptable', desc: 'Returns partition table associated with this host group'
    property :puppet_server, String, desc: 'Returns host name of the server with Puppetserver'
    property :params, Hash, desc: 'Returns parameters of this host group'
    property :puppet_proxy, 'SmartProxy', desc: 'Returns Smart proxy with Puppet feature'
    property :puppet_ca_server, 'SmartProxy', desc: 'Returns Smart proxy Puppet CA feature'
    property :domain, 'Domain', desc: 'Returns domain associated with this host group'
    property :subnet, 'Subnet::Ipv4', desc: 'Returns IPv4 subnet associated with this host group'
    property :hosts, array_of: 'Host', desc: 'Returns all the hosts associated with this host group'
    property :subnet6, 'Subnet::Ipv6', desc: 'Returns IPv6 subnet associated with this host group'
    property :realm, 'Realm', desc: 'Returns realm associated with this host group'
    property :root_pass, String, desc: 'Returns root user\'s encrypted password for the each host associated with this host group'
    property :pxe_loader, String, desc: 'Returns boot loader to be applied on each host within this host group'
    property :title, String, desc: 'Returns full title of this host group, e.g. Base/CentOS 7'
  end
  class Jail < ::Safemode::Jail
    allow :id, :name, :diskLayout, :puppet_server, :operatingsystem, :architecture,
      :ptable, :url_for_boot, :params, :puppet_proxy, :puppet_ca_server,
      :os, :arch, :domain, :subnet, :subnet6, :hosts, :realm,
      :root_pass, :description, :pxe_loader, :title,
      :children, :parent
  end

  # TODO: add a method that returns the valid os for a hostgroup

  def hostgroup
    self
  end

  def self.title_name
    "title".freeze
  end

  def disk_layout_source
    @disk_layout_source ||= if ptable.present?
                              Foreman::Renderer::Source::String.new(name: ptable.name,
                                                                    content: ptable.layout.tr("\r", ''))
                            end
  end

  def diskLayout
    raise Foreman::Renderer::Errors::RenderingError, 'Partition table not defined for hostgroup' unless disk_layout_source
    disk_layout_source.content
  end

  def inherited_lookup_value(key)
    if key.path_elements.flatten.include?("hostgroup") && Setting["matchers_inheritance"]
      ancestors.reverse_each do |hg|
        if (v = LookupValue.find_by(:lookup_key_id => key.id, :id => hg.lookup_values))
          return v.value, hg.to_label
        end
      end
    end
    [key.default_value, _("Default value")]
  end

  def parent_params(include_source = false)
    hash = {}
    ids = ancestor_ids
    # need to pull out the hostgroups to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    groups = Hostgroup.sort_by_ancestry(Hostgroup.includes(:group_parameters).find(ids))
    groups.each do |hg|
      params_arr = hg.group_parameters.authorized(:view_params)
      params_arr.each do |p|
        hash[p.name] = include_source ? p.hash_for_include_source(p.associated_type, hg.title) : p.value
      end
    end
    hash
  end

  # returns self and parent parameters as a hash
  def parameters(include_source = false)
    hash = parent_params(include_source)
    group_parameters.each do |p|
      hash[p.name] = include_source ? p.hash_for_include_source(p.associated_type, title) : p.value
    end
    hash
  end

  def global_parameters
    Hostgroup.sort_by_ancestry(Hostgroup.includes(:group_parameters).find(ancestor_ids + id)).map(&:group_parameters).uniq
  end

  def params
    parameters = {}
    # read common parameters
    CommonParameter.find_each { |p| parameters.update Hash[p.name => p.value] }
    # read OS parameters
    operatingsystem&.os_parameters&.each { |p| parameters.update Hash[p.name => p.value] }
    # read group parameters only if a host belongs to a group
    parameters.update self.parameters if hostgroup
    parameters
  end

  # no need to store anything in the db if the password is our default
  def root_pass
    return self[:root_pass] if self[:root_pass].present?
    npw = nested_root_pw
    return npw if npw.present?
    crypt_pass(Setting[:root_pass], :root)
  end

  def explicit_pxe_loader
    self[:pxe_loader].presence
  end

  def pxe_loader
    explicit_pxe_loader || nested(:pxe_loader).presence
  end

  include_in_clone :lookup_values, :locations, :organizations, :group_parameters
  exclude_from_clone :name, :title, :lookup_value_matcher

  # Clone the hostgroup
  def clone(name = "")
    new = selective_clone
    new.name = name
    new.title = name
    new.lookup_values.each do |lv|
      lv.match = new.lookup_value_match
      lv.host_or_hostgroup = new
    end
    new
  end

  def hosts_count
    HostCounter.new(:hostgroup)[self]
  end

  def children_hosts_count
    counter = HostCounter.new(:hostgroup)
    subtree_ids.map { |child_id| counter.fetch(child_id, 0) }.sum
  end

  # rebuilds orchestration configuration for hostgroup's hosts
  # takes all the methods from Orchestration modules that are registered for configuration rebuild
  # arguments:
  # => only : Array of rebuild methods to execute (Example: ['TFTP'])
  # => children_hosts : Boolean that if true will operate on children hostgroup's hosts
  # returns  : Hash with 'true' if rebuild was a success for a given key (Example: {'host.example.com': {"TFTP" => true, "DNS" => false}})
  def recreate_hosts_config(only = nil, children_hosts = false)
    result = {}

    Host::Managed.authorized.where(:hostgroup => (children_hosts ? subtree_ids : id)).find_each do |host|
      result[host.name] = host.recreate_config(only)
    end
    result
  end

  def render_template(template:, **params)
    template.render(host: self, **params)
  end

  def root_pass_present?
    return true if self[:root_pass].present?
    nested_root_pw
  end

  protected

  def lookup_value_match
    "hostgroup=#{to_label}"
  end

  private

  def nested_root_pw
    if ancestry.present?
      Hostgroup.sort_by_ancestry(ancestors).reverse_each do |a|
        return a.root_pass if a.root_pass.present?
      end
    end
    nil
  end

  # overwrite method in taxonomix, since hostgroup has ancestry
  def used_taxonomy_ids(type)
    return [] if new_record? && parent_id.blank?
    Host::Base.where(:hostgroup_id => path_ids).distinct.pluck(type).compact
  end

  def password_base64_encrypted?
    !root_pass_changed?
  end

  def validate_subnet_types
    errors.add(:subnet, _("must be of type Subnet::Ipv4.")) if subnet.present? && subnet.type != 'Subnet::Ipv4'
    errors.add(:subnet6, _("must be of type Subnet::Ipv6.")) if subnet6.present? && subnet6.type != 'Subnet::Ipv6'
  end

  def validate_compute_profile
    errors.add(:compute_profile, _('is not valid.')) unless ComputeProfile.authorized(:view_compute_profiles).visibles.where(id: compute_profile_id).any?
  end
end
