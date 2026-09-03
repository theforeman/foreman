class Hostgroup < ApplicationRecord
  API_PRELOAD_ASSOCIATIONS = [
    :architecture, :compute_profile, :compute_resource, :domain, :medium,
    :operatingsystem, :ptable, :puppet_ca_proxy, :puppet_proxy,
    :realm, :subnet, :subnet6
  ].freeze

  # Set by HostgroupReadContext during index rendering to reuse request-scoped
  # ancestor, inheritance, and count lookups across hostgroup rows.
  attr_accessor :hostgroup_read_context

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

  validates :name, presence: true, uniqueness: { scope: :ancestry, case_sensitive: false }

  validate :validate_subnet_types
  validates_with SubnetsConsistencyValidator
  validate :validate_compute_profile, :if => proc { |hostgroup| hostgroup.compute_profile_id_changed? && hostgroup.compute_profile_id.present? }

  include ScopedSearchExtensions
  include SelectiveClone

  validates_lengths_from_database :except => [:name]
  before_destroy EnsureNotUsedBy.new(:hosts)
  validates :root_pass, :allow_blank => true, :length => {:minimum => 8, :message => N_('should be 8 characters or more')}
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

  # Override NestedAncestryCommon.nested_attribute_for for Hostgroup so inherited
  # reads go through HostgroupInheritanceResolver / HostgroupReadContext instead
  # of repeating ancestry walks and association lookups per call.
  class << self
    attr_reader :nested_attribute_fields

    def nested_attribute_for(*fields)
      @nested_attribute_fields = fields
      @nested_attribute_fields.each do |field|
        define_method "inherited_#{field}" do
          inherited_nested_attribute(field)
        end

        next unless (md = field.to_s.match(/(\w+)_id$/))

        define_method md[1] do
          if ancestry.present?
            effective_association(md[1].to_sym, field)
          else
            # () is required. Otherwise, get RuntimeError: implicit argument passing of super from method defined by define_method() is not supported. Specify all arguments explicitly.
            super()
          end
        end
      end
    end
  end

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

  apipie :class do
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
  class Jail < Safemode::Jail
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
      ancestor_chain(:lookup_values).reverse_each do |hg|
        if (v = hg.lookup_values.detect { |lookup_value| lookup_value.lookup_key_id == key.id })
          return v.value, hg.to_label
        end
      end
    end
    [key.default_value, _("Default value")]
  end

  def parent_params(include_source = false)
    hash = {}
    ancestor_chain(:group_parameters).each do |hg|
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
    ancestor_chain(:group_parameters, include_self: true).map(&:group_parameters).uniq
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

  def inherited_attributes_for(attributes)
    inheritance_resolver.attributes_for(attributes)
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
    return hostgroup_read_context.direct_host_count_for(self) if hostgroup_read_context.present?

    HostCounter.new(:hostgroup)[self]
  end

  def children_hosts_count
    return hostgroup_read_context.subtree_host_count_for(self) if hostgroup_read_context.present?

    HostgroupSubtreeCounts.new(self.class.unscoped, target_hostgroups: [self]).totals.fetch(id, 0)
  end

  def parent_name
    effective_parent&.title
  end

  def inherited_nested_attribute(attr)
    attr = attr.to_sym
    return self[attr] unless ancestry.present?

    inheritance_resolver.inherited_attribute(attr)
  end

  def nested_attribute_source(attr)
    return unless ancestry.present?

    inheritance_resolver.source_for(attr)
  end

  def nested(attr)
    return unless ancestry.present?

    inheritance_resolver.nested_attribute(attr)
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

  def effective_association(association_name, field)
    if self[field].present?
      association(association_name).reader
    else
      nested_attribute_source(field)&.public_send(association_name)
    end
  end

  def effective_parent
    return hostgroup_read_context.parent_for(self) if hostgroup_read_context.present? && ancestry.present?

    parent
  end

  def inheritance_resolver
    return hostgroup_read_context.resolver_for(self) if hostgroup_read_context.present?

    @inheritance_resolver ||= HostgroupInheritanceResolver.new(self, ancestors: ancestor_chain)
  end

  def nested_root_pw
    ancestor_chain.reverse_each { |a| return a.root_pass if a.root_pass.present? }
    nil
  end

  def ancestor_chain(*associations, include_self: false)
    ids = ancestor_ids
    return include_self ? [self] : [] if ids.empty? && include_self
    return [] if ids.empty?

    loaded_ancestors = if hostgroup_read_context.present?
                         hostgroup_read_context.ancestors_for(self)
                       else
                         scope = self.class.where(id: ids)
                         scope = scope.includes(*associations.flatten) if associations.present?
                         self.class.sort_by_ancestry(scope.to_a)
                       end
    include_self ? loaded_ancestors + [self] : loaded_ancestors
  end

  # overwrite method in taxonomix, since hostgroup has ancestry
  def used_taxonomy_ids(type)
    return [] if new_record? && parent_id.blank?
    Host::Base.where(:hostgroup_id => path_ids).distinct.pluck(type).compact
  end

  def password_base64_encrypted?
    !(self[:root_pass].blank? && nested_root_pw.blank?) && !root_pass_changed?
  end

  def validate_subnet_types
    errors.add(:subnet, _("must be of type Subnet::Ipv4.")) if subnet.present? && subnet.type != 'Subnet::Ipv4'
    errors.add(:subnet6, _("must be of type Subnet::Ipv6.")) if subnet6.present? && subnet6.type != 'Subnet::Ipv6'
  end

  def validate_compute_profile
    errors.add(:compute_profile, _('is not valid.')) unless ComputeProfile.authorized(:view_compute_profiles).visibles.where(id: compute_profile_id).any?
  end
end
