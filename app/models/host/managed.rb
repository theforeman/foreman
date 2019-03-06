class Host::Managed < Host::Base
  # audit the changes to this model
  audited :except => [:last_report, :last_compile, :lookup_value_matcher, :global_status]
  has_associated_audits
  # redefine audits relation because of the type change (by default the relation will look for auditable_type = 'Host::Managed')
  has_many :audits, -> { where(:auditable_type => 'Host::Base') }, :foreign_key => :auditable_id,
           :class_name => 'Audited::Audit'

  include Hostext::PowerInterface
  include Hostext::Search
  include Hostext::SmartProxy
  include Hostext::Token
  include Hostext::OperatingSystem
  include Hostext::Puppetca
  include SelectiveClone
  include HostInfoExtensions
  include HostParams
  include Facets::ManagedHostExtensions

  has_many :host_classes, :foreign_key => :host_id
  has_many :puppetclasses, :through => :host_classes, :dependent => :destroy
  has_many :reports, :foreign_key => :host_id, :class_name => 'ConfigReport'
  has_one :last_report_object, -> { order("#{Report.table_name}.id DESC") }, :foreign_key => :host_id, :class_name => 'ConfigReport'
  has_many :all_reports, :foreign_key => :host_id

  belongs_to :image
  has_many :host_statuses, :class_name => 'HostStatus::Status', :foreign_key => 'host_id', :inverse_of => :host, :dependent => :destroy
  has_one :configuration_status_object, :class_name => 'HostStatus::ConfigurationStatus', :foreign_key => 'host_id'
  before_destroy :remove_reports

  def self.complete_for(query, opts = {})
    matcher = /(\s*(?:(?:user\.[a-z]+)|owner)\s*[=~])\s*(\S*)\s*\z/
    matches = matcher.match(query)
    output = super(query, opts)
    if matches.present? && 'current_user'.start_with?(matches[2])
      current_user_result = query.sub(matcher, '\1 current_user')
      output = [current_user_result] + output
    end
    output
  end

  # Define custom hook that can be called in model by magic methods (before, after, around)
  define_model_callbacks :build, :only => :after
  define_model_callbacks :provision, :only => :before
  prepend Hostext::UINotifications

  before_validation :refresh_build_status, :if => :build_changed?

  # Custom hooks will be executed after_commit
  after_commit :build_hooks
  before_save :clear_data_on_build
  before_save :clear_puppetinfo, :if => :environment_id_changed?

  include PxeLoaderValidator

  def initialize(*args)
    args.unshift(apply_inherited_attributes(args.shift, false))
    super(*args)
  end

  def build_hooks
    return if previous_changes['build'].nil?
    if build?
      run_callbacks :build do
        logger.debug "custom hook after_build on #{name} will be executed if defined."
        true
      end
    else
      run_callbacks :provision do
        logger.debug "custom hook before_provision on #{name} will be executed if defined."
        true
      end
    end
  end

  include HostCommon

  smart_proxy_reference :subnet => [:dns_id, :dhcp_id, :tftp_id]
  smart_proxy_reference :subnet6 => [:dns_id, :dhcp_id, :tftp_id]
  smart_proxy_reference :domain => [:dns_id]
  smart_proxy_reference :realm => [:realm_proxy_id]
  smart_proxy_reference :self => [:puppet_proxy_id, :puppet_ca_proxy_id]

  class Jail < ::Safemode::Jail
    allow :name, :diskLayout, :puppetmaster, :puppet_ca_server, :operatingsystem, :os, :environment, :ptable, :hostgroup,
      :url_for_boot, :hostgroup, :compute_resource, :domain, :ip, :ip6, :mac, :shortname, :architecture,
      :model, :certname, :capabilities, :provider, :subnet, :subnet6, :token, :location, :organization, :provision_method,
      :image_build?, :pxe_build?, :otp, :realm, :nil?, :indent, :primary_interface,
      :provision_interface, :interfaces, :bond_interfaces, :bridge_interfaces, :interfaces_with_identifier,
      :managed_interfaces, :facts, :facts_hash, :root_pass, :sp_name, :sp_ip, :sp_mac, :sp_subnet, :use_image,
      :multiboot, :jumpstart_path, :install_path, :miniroot, :medium, :bmc_nic, :templates_used, :owner, :owner_type,
      :ssh_authorized_keys, :pxe_loader, :global_status, :get_status, :puppetca_token, :last_report
  end

  scope :recent, lambda { |interval = Setting[:outofsync_interval]|
    with_last_report_within(interval.to_i.minutes)
  }

  scope :out_of_sync, lambda { |interval = Setting[:outofsync_interval]|
    not_disabled.with_last_report_exceeded(interval.to_i.minutes)
  }

  scope :out_of_sync_for, lambda { |report_origin|
    interval = Setting[:"#{report_origin.downcase}_interval"] || Setting[:outofsync_interval]
    with_last_report_exceeded(interval.to_i.minutes)
      .not_disabled
      .with_last_report_origin(report_origin)
  }

  scope :not_disabled, lambda {
    where(["#{Host.table_name}.enabled != ?", false])
  }

  scope :with_last_report_within, lambda { |minutes|
    where(["#{Host.table_name}.last_report > ?", minutes.ago])
  }

  scope :with_last_report_exceeded, lambda { |minutes|
    where(["#{Host.table_name}.last_report < ?", minutes.ago])
  }

  scope :with_last_report_origin, lambda { |origin|
    includes(:last_report_object).where(reports: { origin: origin })
  }

  scope :with_status, lambda { |status_type|
    eager_load(:host_statuses).where("host_status.type = '#{status_type}'")
  }

  scope :with_config_status, lambda {
    with_status('HostStatus::ConfigurationStatus')
  }

  # search for a metric - e.g.:
  # Host::Managed.with("failed") --> all reports which have a failed counter > 0
  # Host::Managed.with("failed",20) --> all reports which have a failed counter > 20
  scope :with, lambda { |*arg|
    with_config_status.where("(host_status.status >> #{HostStatus::ConfigurationStatus.bit_mask(arg[0].to_s)}) > #{arg[1] || 0}")
  }

  scope :with_error, lambda {
    with_config_status.where("(host_status.status > 0) and (
      #{HostStatus::ConfigurationStatus.is('failed')} or
      #{HostStatus::ConfigurationStatus.is('failed_restarts')}
    )")
  }

  scope :without_error, lambda {
    with_config_status.where("
      #{HostStatus::ConfigurationStatus.is_not('failed')} and
      #{HostStatus::ConfigurationStatus.is_not('failed_restarts')}
    ")
  }

  scope :with_changes, lambda {
    with_config_status.where("(host_status.status > 0) and (
      #{HostStatus::ConfigurationStatus.is('applied')} or
      #{HostStatus::ConfigurationStatus.is('restarted')}
    )")
  }

  scope :without_changes, lambda {
    with_config_status.where("
      #{HostStatus::ConfigurationStatus.is_not('applied')} and
      #{HostStatus::ConfigurationStatus.is_not('restarted')}
    ")
  }

  scope :with_pending_changes, lambda {
    with_config_status.where("(host_status.status > 0) AND (#{HostStatus::ConfigurationStatus.is('pending')})")
  }

  scope :without_pending_changes, lambda {
    with_config_status.where(HostStatus::ConfigurationStatus.is_not('pending').to_s)
  }

  scope :successful, -> { without_changes.without_error.without_pending_changes}

  scope :alerts_disabled, -> { where(:enabled => false) }

  scope :alerts_enabled, -> { where(:enabled => true) }

  scope :run_distribution, lambda { |fromtime, totime|
    if fromtime.nil? || totime.nil?
      raise ::Foreman.Exception.new(N_("invalid time range"))
    else
      joins("INNER JOIN reports ON reports.host_id = hosts.id").where("reports.reported_at BETWEEN ? AND ?", fromtime, totime)
    end
  }

  scope :with_any_reports_between, lambda { |from, to|
    joins(:all_reports).where("reports.reported_at BETWEEN ? AND ?", from, to)
  }

  scope :for_vm, ->(cr, vm) { where(:compute_resource_id => cr.id, :uuid => Array.wrap(vm).compact.map(&:identity).map(&:to_s)) }

  scope :with_compute_resource, -> { where.not(:compute_resource_id => nil, :uuid => nil) }

  scope :in_build_mode, -> { where(build: true) }
  scope :with_build_errors, -> { where.not(build_errors: nil) }

  # some shortcuts
  alias_attribute :arch, :architecture

  validates :environment_id, :presence => true, :unless => Proc.new { |host| host.puppet_proxy_id.blank? }
  validates :organization_id, :presence => true, :if => Proc.new { |host| host.managed? && SETTINGS[:organizations_enabled] }
  validates :location_id,     :presence => true, :if => Proc.new { |host| host.managed? && SETTINGS[:locations_enabled] }
  validate :compute_resource_in_taxonomy, :if => Proc.new { |host| host.managed? && host.compute_resource_id.present? }

  if SETTINGS[:unattended]
    # define before orchestration is included so we can prepare object before VM is tried to be deleted
    before_destroy :disassociate!, :if => Proc.new { |host| host.uuid && !Setting[:destroy_vm_on_host_delete] }
    # handles all orchestration of smart proxies.
    include Orchestration
    # DHCP orchestration delegation
    delegate :dhcp?, :dhcp_records, :to => :primary_interface
    # DNS orchestration delegation
    delegate :dns?, :dns6?, :reverse_dns?, :reverse_dns6?, :dns_record, :to => :primary_interface
    # IP delegation
    delegate :mac_based_ipam?, :required_ip_addresses_set?, :compute_provides_ip?, :ip_available?, :ip6_available?, :to => :primary_interface
    include Orchestration::Compute
    include Rails.application.routes.url_helpers
    # TFTP orchestration delegation
    delegate :tftp?, :tftp6?, :tftp, :tftp6, :generate_pxe_template, :to => :provision_interface
    include Orchestration::Puppetca
    include Orchestration::SSHProvision
    include Orchestration::Realm
    include HostTemplateHelpers
    delegate :require_ip4_validation?, :require_ip6_validation?, :to => :provision_interface

    validates :architecture_id, :presence => true, :if => Proc.new {|host| host.managed}
    validates :root_pass, :length => {:minimum => 8, :message => _('should be 8 characters or more')},
                          :presence => {:message => N_('should not be blank - consider setting a global or host group default')},
                          :if => Proc.new { |host| host.managed && !host.image_build? && build? }
    validates :ptable_id, :presence => {:message => N_("can't be blank unless a custom partition has been defined")},
                          :if => Proc.new { |host| host.managed && host.disk.empty? && !Foreman.in_rake? && !host.image_build? && host.build? }
    validates :provision_method, :inclusion => {:in => Proc.new { self.provision_methods }, :message => N_('is unknown')}, :if => Proc.new {|host| host.managed?}
    validates :medium_id, :presence => true,
                          :if => Proc.new { |host| host.validate_media? }
    validates :medium_id, :inclusion => {:in => Proc.new { |host| host.operatingsystem.medium_ids },
                                         :message => N_('must belong to host\'s operating system')},
                          :if => Proc.new { |host| host.operatingsystem && host.medium }
    validate :provision_method_in_capabilities
    validate :short_name_periods
    validate :check_interfaces
    before_validation :set_compute_attributes, :on => :create, :if => Proc.new { compute_attributes_empty? }
    validate :check_if_provision_method_changed, :on => :update, :if => Proc.new { |host| host.managed }
    validates :uuid, uniqueness: { :allow_blank => true }
  else
    def fqdn
      facts['fqdn'] || name
    end

    def compute?
      false
    end

    def compute_provides?(attr)
      false
    end
  end

  before_validation :set_hostgroup_defaults, :set_ip_address
  after_validation :ensure_associations
  before_validation :set_certname, :if => Proc.new {|h| h.managed? && Setting[:use_uuid_for_certificates] } if SETTINGS[:unattended]
  after_validation :trigger_nic_orchestration, :if => Proc.new { |h| h.managed? && h.changed? }, :on => :update
  before_validation :validate_dns_name_uniqueness

  def <=>(other)
    self.name <=> other.name
  end

  def owner_name
    owner.try(:name)
  end

  def self.model_name
    ActiveModel::Name.new(Host)
  end

  # Permissions introduced by plugins for this class can cause resource <-> permission
  # names mapping to fail randomly so as a safety precaution, we specify the name more explicitly.
  def self.find_permission_name(action)
    "#{action}_hosts"
  end

  def clear_reports
    # Remove any reports that may be held against this host
    Report.where("host_id = #{id}").delete_all
    self.last_report = nil
  end

  def clear_facts
    FactValue.where("host_id = #{id}").delete_all
  end

  def clear_data_on_build
    return unless respond_to?(:old) && old && build? && !old.build?
    clear_facts
    clear_reports
    self.build_errors = nil
  end

  # Called from the host build post install process to indicate that the base build has completed
  # Build is cleared and the boot link and autosign entries are removed
  # A site specific build script is called at this stage that can do site specific tasks
  def built(installed = true)
    # delete all expired tokens
    self.build        = false
    self.otp          = nil
    self.installed_at = Time.now.utc if installed

    if self.save
      send_built_notification if installed
      true
    else
      logger.warn "Failed to set Build on #{self}: #{self.errors.full_messages}"
      false
    end
  end

  def import_facts(facts, source_proxy = nil)
    # Facts come from 'existing' attributes/infrastructure. We skip triggering
    # the orchestration of this infrastructure when we create a host this way.
    skip_orchestration! if SETTINGS[:unattended] && !SETTINGS[:enable_orchestration_on_fact_import]
    super
  ensure
    enable_orchestration! if SETTINGS[:unattended] && !SETTINGS[:enable_orchestration_on_fact_import]
  end

  # Request a new OTP for a host
  def handle_realm
    return true unless realm?

    # If no OTP is set, then this is probably a rebuild
    if self.otp.blank?
      logger.info "Setting realm for host #{name}"
      set_realm :rebuild => true
      self.save!
    else
      true
    end
  end

  def disk_layout_source
    @disk_layout_source ||= if disk.present?
                              Foreman::Renderer::Source::String.new(name: 'Custom disk layout',
                                                                    content: disk.tr("\r", ''))
                            elsif ptable.present?
                              Foreman::Renderer::Source::Database.new(ptable)
                            end
  end

  # returns the host correct disk layout, custom or common
  def diskLayout
    raise Foreman::Renderer::Errors::RenderingError, 'Neither disk nor partition table defined for host' unless disk_layout_source
    scope = Foreman::Renderer.get_scope(host: self, source: disk_layout_source)
    Foreman::Renderer.render(disk_layout_source, scope)
  end

  # reports methods
  def error_count
    %w[failed failed_restarts].sum {|f| status f}
  end

  def no_report
    last_report.nil? || last_report < Time.now.utc - origin_interval.minutes && enabled?
  end

  def origin_interval
    Setting[:"#{last_report.origin.downcase}_interval"] || 0
  end

  def disabled?
    !enabled?
  end

  # Determine if host is setup for configuration
  def configuration?
    puppet_proxy_id.present?
  end

  # the environment used by #clases nees to be self.environment and not self.parent.environment
  def parent_classes
    return [] unless hostgroup
    hostgroup.classes(environment)
  end

  def parent_config_groups
    return [] unless hostgroup
    hostgroup.all_config_groups
  end

  # returns the list of puppetclasses a host is in.
  def puppetclasses_names
    all_puppetclasses.collect {|c| c.name}
  end

  def attributes_to_import_from_facts
    attrs = [:architecture, :hostgroup]
    if !Setting[:ignore_facts_for_operatingsystem] || (Setting[:ignore_facts_for_operatingsystem] && operatingsystem.blank?)
      attrs << :operatingsystem
    end
    if !Setting[:ignore_facts_for_domain] || (Setting[:ignore_facts_for_domain] && domain.blank?)
      attrs << :domain
    end

    super + attrs
  end

  def populate_fields_from_facts(parser, type, source_proxy)
    super
    update_os_from_facts if operatingsystem_id_changed?
    populate_facet_fields(parser, type, source_proxy)
  end

  # Called by build link in the list
  # Build is set
  # The boot link and autosign entry are created
  # Any existing puppet certificates are deleted
  # Any facts are discarded
  def setBuild
    self.build = true
    self.initiated_at = Time.now.utc
    logger.warn("Set build failed: #{errors.inspect}") unless self.save
    errors.empty?
  end

  # this method accepts a puppets external node yaml output and generate a node in our setup
  # it is assumed that you already have the node (e.g. imported by one of the rack tasks)
  def importNode(nodeinfo)
    myklasses = []
    # puppet classes
    classes = nodeinfo["classes"]
    classes = classes.keys if classes.is_a?(Hash)
    classes.each do |klass|
      if (pc = Puppetclass.find_by_name(klass.to_s))
        myklasses << pc
      else
        error = _("Failed to import %{klass} for %{name}: doesn't exists in our database - ignoring") % { :klass => klass, :name => name }
        logger.warn error
        $stdout.puts error
      end
      self.puppetclasses = myklasses
    end

    # parameters are a bit more tricky, as some classifiers provide the facts as parameters as well
    # not sure what is puppet priority about it, but we ignore it if has a fact with the same name.
    # additionally, we don't import any non strings values, as puppet don't know what to do with those as well.

    myparams = self.info["parameters"]
    nodeinfo["parameters"].each_pair do |param, value|
      next if fact_names.exists? :name => param
      next unless value.is_a?(String)

      # we already have this parameter
      next if myparams.has_key?(param) && myparams[param] == value

      unless (hp = self.host_parameters.create(:name => param, :value => value))
        logger.warn "Failed to import #{param}/#{value} for #{name}: #{hp.errors.full_messages.join(', ')}"
        $stdout.puts $ERROR_INFO
      end
    end

    self.clear_host_parameters_cache!
    self.save
  end

  # counts each association of a given host
  # e.g. how many hosts belongs to each os
  # returns sorted hash
  def self.count_distribution(association)
    output = []
    data = group("#{Host.table_name}.#{association}_id").reorder('').count
    associations = association.to_s.camelize.constantize.where(:id => data.keys).all
    data.each do |k, v|
      begin
        output << {:label => associations.detect {|a| a.id == k }.to_label, :data => v } unless v == 0
      rescue
        logger.info "skipped #{k} as it has has no label"
      end
    end
    output
  end

  # counts each association of a given host for HABTM relationships
  # TODO: Merge these two into one method
  # e.g. how many hosts belongs to each os
  # returns sorted hash
  def self.count_habtm(association)
    counter = Host::Managed.joins(association.tableize.to_sym).group("#{association.tableize.to_sym}.id").reorder('').count
    # Puppetclass.find(counter.keys.compact)...
    association.camelize.constantize.find(counter.keys.compact).map {|i| {:label => i.to_label, :data => counter[i.id]}}
  end

  def self.provision_methods
    {
      'build' => N_('Network Based'),
      'image' => N_('Image Based')
    }.merge(registered_provision_methods)
  end

  def self.registered_provision_methods
    Foreman::Plugin.all.map(&:provision_methods).inject(:merge) || {}
  end

  def self.valid_rebuild_only_values
    if Host::Managed.respond_to?(:rebuild_methods)
      Nic::Managed.rebuild_methods.values + Host::Managed.rebuild_methods.values
    else
      Nic::Managed.rebuild_methods.values
    end
  end

  def can_be_built?
    managed? && SETTINGS[:unattended] && !image_build? && !build?
  end

  def hostgroup_inherited_attributes
    %w{puppet_proxy_id puppet_ca_proxy_id environment_id compute_profile_id realm_id compute_resource_id}
  end

  def apply_inherited_attributes(attributes, initialized = true)
    return nil unless attributes

    attributes = hash_clone(attributes).with_indifferent_access

    new_hostgroup_id = attributes['hostgroup_id'] || attributes['hostgroup_name'] || attributes['hostgroup'].try(:id)
    # hostgroup didn't change, no inheritance needs update.
    return attributes if new_hostgroup_id.blank?

    new_hostgroup = self.hostgroup if initialized
    unless [new_hostgroup.try(:id), new_hostgroup.try(:friendly_id)].include? new_hostgroup_id
      new_hostgroup = Hostgroup.friendly.find(new_hostgroup_id)
    end
    return attributes unless new_hostgroup

    inherited_attributes = hostgroup_inherited_attributes - attributes.keys

    inherited_attributes.each do |attribute|
      value = new_hostgroup.send("inherited_#{attribute}")
      attributes[attribute] = value
    end

    attributes = apply_facet_attributes(new_hostgroup, attributes)
    attributes
  end

  def hash_clone(value)
    if value.is_a? Hash
      # Prefer dup to constructing a new object to perserve permitted state
      # when `value` is an ActionController::Parameters instance
      new_hash = value.dup
      new_hash.each { |k, v| new_hash[k] = hash_clone(v) }
      return new_hash
    end

    value
  end

  def set_hostgroup_defaults(force = false)
    return unless hostgroup
    assign_hostgroup_attributes(inherited_attributes, force)
  end

  def inherited_attributes
    inherited_attrs = %w{domain_id}
    if SETTINGS[:unattended]
      inherited_attrs.concat(%w{operatingsystem_id architecture_id compute_resource_id})
      inherited_attrs << "subnet_id" unless compute_provides?(:ip)
      inherited_attrs << "subnet6_id" unless compute_provides?(:ip6)
      inherited_attrs.concat(%w{medium_id ptable_id pxe_loader}) unless image_build?
    end
    inherited_attrs
  end

  def set_compute_attributes
    if compute_profile_present?
      self.compute_attributes = compute_resource.compute_profile_attributes_for(compute_profile_id)
    elsif compute_resource
      self.compute_attributes ||= {}
    end
  end

  def set_ip_address
    return unless SETTINGS[:unattended] && (new_record? || managed?)
    self.interfaces.select { |nic| nic.managed }.each do |nic|
      nic.ip  = nic.subnet.unused_ip(mac).suggest_ip if nic.subnet.present? && nic.ip.blank?
      nic.ip6 = nic.subnet6.unused_ip(mac).suggest_ip if nic.subnet6.present? && nic.ip6.blank?
    end
  end

  def associate!(cr, vm)
    self.uuid = vm.identity
    self.compute_resource_id = cr.id
    self.save!(:validate => false) # don't want to trigger callbacks
  end

  def disassociate!
    self.uuid = nil
    self.compute_resource_id = nil
    self.save!(:validate => false) # don't want to trigger callbacks
  end

  def puppetrun!
    unless puppet_proxy.present?
      errors.add(:base, _("no puppet proxy defined - cant continue"))
      logger.warn "unable to execute puppet run, no puppet proxies defined"
      return false
    end
    ProxyAPI::Puppet.new({:url => puppet_proxy.url}).run fqdn
  rescue => e
    errors.add(:base, _("failed to execute puppetrun: %s") % e)
    Foreman::Logging.exception("Unable to execute puppet run", e)
    false
  end

  # if certname does not exist, use hostname instead
  def certname
    self[:certname] || name
  end

  def capabilities
    compute_resource ? compute_resource.capabilities : bare_metal_capabilities
  end

  def bare_metal_capabilities
    [:build]
  end

  def provider
    if compute_resource_id
      compute_resource.provider_friendly_name
    else
      "BareMetal"
    end
  end

  # no need to store anything in the db if the password is our default
  def root_pass
    return self[:root_pass] if self[:root_pass].present?
    return hostgroup.try(:root_pass) if hostgroup.try(:root_pass).present?
    Setting[:root_pass]
  end

  include_in_clone :config_groups, :host_config_groups, :host_classes, :host_parameters, :lookup_values
  exclude_from_clone :name, :uuid, :certname, :last_report, :lookup_value_matcher

  def clone
    # do not copy system specific attributes
    host = self.selective_clone

    host.interfaces = self.interfaces.map(&:clone)
    if self.compute_resource
      host.compute_attributes = host.compute_resource.vm_compute_attributes_for(self.uuid)
    end
    host.refresh_global_status
    host
  end

  def check_interfaces
    errors.add(:base, _("An interface marked as provision is missing")) if self.interfaces.detect(&:provision).nil?
    errors.add(:base, _("An interface marked as primary is missing")) if self.interfaces.detect(&:primary).nil?
  end

  def bmc_nic
    interfaces.bmc.first
  end

  def sp_ip
    bmc_nic.try(:ip)
  end

  def sp_mac
    bmc_nic.try(:mac)
  end

  def sp_subnet_id
    bmc_nic.try(:subnet_id)
  end

  def sp_subnet
    bmc_nic.try(:subnet)
  end

  def sp_name
    bmc_nic.try(:name)
  end

  def vm_compute_attributes
    compute_resource ? compute_resource.vm_compute_attributes_for(uuid) : nil
  end

  def bmc_proxy
    @bmc_proxy ||= bmc_nic.proxy
  end

  def bmc_available?
    ipmi = bmc_nic
    return false if ipmi.nil?
    (ipmi.password.present? && ipmi.username.present? && ipmi.provider == 'IPMI') || ipmi.provider == 'SSH'
  end

  def ipmi_boot(booting_device)
    unless bmc_available?
      raise Foreman::Exception.new(
        _("No BMC NIC available for host %s") % self)
    end
    bmc_proxy.boot({:function => 'bootdevice', :device => booting_device})
  end

  # take from hostgroup if compute_profile_id is nil
  def compute_profile_id
    self[:compute_profile_id] || hostgroup.try(:compute_profile_id)
  end

  def provision_method
    self[:provision_method] || capabilities.first.to_s
  end

  def explicit_pxe_loader
    self[:pxe_loader].presence
  end

  def pxe_loader
    explicit_pxe_loader || hostgroup.try(:pxe_loader)
  end

  def image_build?
    self.provision_method == 'image'
  end

  def pxe_build?
    self.provision_method == 'build'
  end

  def validate_media?
    managed && !image_build? && build?
  end

  def build_status_checker
    build_status = HostBuildStatus.new(self)
    build_status.check_all_statuses
    build_status
  end

  def refresh_global_status
    self.global_status = build_global_status.status
  end

  def refresh_global_status!
    refresh_global_status
    save!(:validate => false)
  end

  def refresh_statuses(which = HostStatus.status_registry)
    which.each do |status_class|
      status = get_status(status_class)
      status.refresh! if status.relevant?
    end
    host_statuses.reload
    refresh_global_status!
  end

  def get_status(type)
    status = host_statuses.detect { |s| s.type == type.to_s }
    if status.nil?
      host_statuses.new(:host => self, :type => type.to_s)
    else
      status
    end
  end

  def build_global_status(options = {})
    HostStatus::Global.build(host_statuses, options)
  end

  def global_status_label(options = {})
    HostStatus::Global.build(host_statuses, options).to_label
  end

  def configuration_status(options = {})
    @configuration_status ||= get_status(HostStatus::ConfigurationStatus).to_status(options)
  end

  def configuration_status_label(options = {})
    @configuration_status_label ||= get_status(HostStatus::ConfigurationStatus).to_label(options)
  end

  def build_status(options = {})
    @build_status ||= get_status(HostStatus::BuildStatus).to_status(options)
  end

  def build_status_label(options = {})
    @build_status_label ||= get_status(HostStatus::BuildStatus).to_label(options)
  end

  # rebuilds orchestration configuration for a host
  # takes all the methods from Orchestration modules that are registered for configuration rebuild
  # arguments:
  # => only : Array of rebuild methods to execute (Example: ['TFTP'])
  # returns  : Hash with 'true' if rebuild was a success for a given key (Example: {"TFTP" => true, "DNS" => false})
  def recreate_config(only = nil)
    result = {}

    Nic::Managed.rebuild_methods_for(only).map do |method, pretty_name|
      interfaces.map do |interface|
        value = interface.send method
        result[pretty_name] = value if !result.has_key?(pretty_name) || (result[pretty_name] && !value)
      end
    end

    self.class.rebuild_methods_for(only).map do |method, pretty_name|
      raise ::Foreman::Exception.new(N_("There are orchestration modules with methods for configuration rebuild that have identical name: '%s'"), pretty_name) if result[pretty_name]
      result[pretty_name] = self.send method
    end
    result
  end

  def apply_compute_profile(modification)
    modification.run(self, compute_resource.try(:compute_profile_for, compute_profile_id))
  end

  def firmware_type
    return unless pxe_loader.present?
    Operatingsystem.firmware_type(pxe_loader)
  end

  def compute_resource_or_model
    return self.compute_resource.name if self.compute_resource
    self.hardware_model_name
  end

  def local_boot_template_name(kind)
    key = "local_boot_#{kind}"
    host_params[key] || Setting[key]
  end

  private

  def update_os_from_facts
    operatingsystem.architectures << architecture if operatingsystem && architecture && !operatingsystem.architectures.include?(architecture)
    self.medium = nil if medium&.operatingsystems&.exclude?(operatingsystem)
  end

  # Permissions introduced by plugins for this class can cause resource <-> permission
  # names mapping to fail randomly so as a safety precaution, we specify the name more explicitly.
  def permission_name(action)
    "#{action}_hosts"
  end

  def compute_profile_present?
    !(compute_profile_id.nil? || compute_resource_id.nil?)
  end

  def compute_attributes_empty?
    compute_attributes.blank?
  end

  # validate uniqueness can't prevent saving two interfaces that has same DNS name
  # because the validation happens before transaction is committed, so data are not in DB
  # yet, this is the reason why we "reimplement" uniqueness validation
  def validate_dns_name_uniqueness
    dups = self.interfaces.select { |i| !i.marked_for_destruction? }.group_by { |i| [ i.name, i.domain_id ] }.detect { |dns, nics| dns.first.present? && nics.count > 1 }
    if dups.present?
      dups.last.first.errors.add(:name, :taken)
      self.errors.add :interfaces, _('Some interfaces are invalid')
      throw :abort
    end
  end

  def assign_hostgroup_attributes(attrs = [], force = false)
    attrs.each do |attr|
      next if send(attr).to_i == -1
      value = hostgroup.send("inherited_#{attr}")
      assign_hostgroup_attribute attr, value, force
    end
  end

  def assign_hostgroup_attribute(attr, value, force)
    self.send("#{attr}=", value) if force || send(attr).blank?
  end

  # checks if the host association is a valid association for this host
  def ensure_associations
    status = true
    if SETTINGS[:unattended] && managed? && os && !image_build?
      %w{ptable medium architecture}.each do |e|
        value = self.send(e.to_sym)
        next if value.blank?
        unless os.send(e.pluralize.to_sym).include?(value)
          errors.add("#{e}_id".to_sym, _("%{value} does not belong to %{os} operating system") % { :value => value, :os => os })
          status = false
        end
      end
    end

    status = validate_association_taxonomy(:environment)

    if environment
      puppetclasses.select("puppetclasses.id,puppetclasses.name").distinct.each do |e|
        unless environment.puppetclasses.map(&:id).include?(e.id)
          errors.add(:puppetclasses, _("%{e} does not belong to the %{environment} environment") % { :e => e, :environment => environment })
          status = false
        end
      end
    end
    status
  end

  def set_certname
    self.certname = Foreman.uuid if self[:certname].blank? || new_record?
  end

  def provision_method_in_capabilities
    return unless managed?
    methods_available = capabilities.map(&:to_s)
    errors.add(:provision_method, _('is an unsupported provisioning method, available: %s') % methods_available.join(',')) unless methods_available.include?(self.provision_method)
  end

  def check_if_provision_method_changed
    if self.provision_method_changed? && !provision_method_changed?(from: nil, to: capabilities.first.to_s)
      errors.add(:provision_method, _("can't be updated after host is provisioned"))
    end
  end

  def short_name_periods
    errors.add(:name, _("must not include periods")) if (managed? && shortname && shortname.include?(".") && SETTINGS[:unattended])
  end

  # we need this so when attribute like build changes we trigger tftp orchestration so token is updated on tftp
  # but we should trigger it only for existing records and unless interfaces also changed (then validation is run
  # on them automatically)
  def trigger_nic_orchestration
    self.primary_interface.valid? if self.primary_interface && !self.primary_interface.changed?
    unless self.provision_interface.nil?
      return if self.primary_interface == self.provision_interface
      self.provision_interface.valid? if self.provision_interface && !self.provision_interface.changed?
    end
  end

  # For performance reasons logs and reports are deleted in batch
  # see http://projects.theforeman.org/issues/8316 for details
  def remove_reports
    host_reports = Report.where(host_id: id)
    Log.where(report_id: host_reports.pluck(:id)).delete_all
    host_reports.delete_all
  end

  def clear_puppetinfo
    unless environment
      self.puppetclasses = []
      self.config_groups = []
    end
  end

  def refresh_build_status
    self.get_status(HostStatus::BuildStatus).refresh
  end

  def extract_params_from_object_ancestors(object)
    params = []
    object_parameters_symbol = "#{object.class.to_s.downcase}_parameters".to_sym
    object.class.sort_by_ancestry(object.ancestors).each {|o| params += o.send(object_parameters_symbol).authorized(:view_params)}
    params += object.send(object_parameters_symbol).authorized(:view_params)
    params
  end

  def send_built_notification
    recipients = owner ? owner.recipients_for(:host_built) : []
    MailNotification[:host_built].deliver(self, :users => recipients) if recipients.present?
  rescue SocketError, Net::SMTPError => e
    Foreman::Logging.exception("Host has been created. Failed to send email", e)
  end

  # Ensures that object assigned in the association belongs to the taxonomies of the host.
  # Returns true if it does, otherwise it adds a validation error and returns false.
  def validate_association_taxonomy(association_name)
    association = self.class.reflect_on_association(association_name)
    raise ArgumentError, "Association #{association_name} not found" unless association
    associated_object_id = public_send(association.foreign_key)
    if associated_object_id.present? &&
      association.klass.with_taxonomy_scope(organization, location).find_by(id: associated_object_id).blank?
      errors.add(association.foreign_key, _("with id %{object_id} doesn't exist or is not assigned to proper organization and/or location") % { :object_id => associated_object_id })
      false
    else
      true
    end
  end

  def compute_resource_in_taxonomy
    validate_association_taxonomy(:compute_resource)
  end
end
