class Host::Managed < Host::Base
  include Hostext::PowerInterface
  include Hostext::Search
  include Hostext::SmartProxy
  include Hostext::Token
  include Hostext::OperatingSystem
  include SelectiveClone
  include HostInfoExtensions
  include HostParams
  include Facets::ManagedHostExtensions

  has_many :host_classes, :foreign_key => :host_id
  has_many :puppetclasses, :through => :host_classes, :dependent => :destroy
  has_many :reports, :foreign_key => :host_id, :class_name => 'ConfigReport'
  has_one :last_report_object, -> { order("#{Report.table_name}.id DESC") }, :foreign_key => :host_id, :class_name => 'ConfigReport'

  belongs_to :compute_resource
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

  class Jail < ::Safemode::Jail
    allow :name, :diskLayout, :puppetmaster, :puppet_ca_server, :operatingsystem, :os, :environment, :ptable, :hostgroup,
      :url_for_boot, :params, :info, :hostgroup, :compute_resource, :domain, :ip, :ip6, :mac, :shortname, :architecture,
      :model, :certname, :capabilities, :provider, :subnet, :subnet6, :token, :location, :organization, :provision_method,
      :image_build?, :pxe_build?, :otp, :realm, :param_true?, :param_false?, :nil?, :indent, :primary_interface,
      :provision_interface, :interfaces, :bond_interfaces, :bridge_interfaces, :interfaces_with_identifier,
      :managed_interfaces, :facts, :facts_hash, :root_pass, :sp_name, :sp_ip, :sp_mac, :sp_subnet, :use_image,
      :multiboot, :jumpstart_path, :install_path, :miniroot, :medium, :bmc_nic, :templates_used, :owner, :owner_type, :ssh_authorized_keys
  end

  scope :recent,      ->(*args) { where(["last_report > ?", (args.first || (Setting[:puppet_interval] + Setting[:outofsync_interval]).minutes.ago)]) }
  scope :out_of_sync, ->(*args) { where(["last_report < ? and hosts.enabled != ?", (args.first || (Setting[:puppet_interval] + Setting[:outofsync_interval]).minutes.ago), false]) }

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
    with_config_status.where((HostStatus::ConfigurationStatus.is_not('pending')).to_s)
  }

  scope :successful, -> { without_changes.without_error.without_pending_changes}

  scope :alerts_disabled, -> { where(:enabled => false) }

  scope :alerts_enabled, -> { where(:enabled => true) }

  scope :run_distribution, lambda { |fromtime,totime|
    if fromtime.nil? || totime.nil?
      raise ::Foreman.Exception.new(N_("invalid time range"))
    else
      joins("INNER JOIN reports ON reports.host_id = hosts.id").where("reports.reported_at BETWEEN ? AND ?", fromtime, totime)
    end
  }

  scope :for_vm, ->(cr,vm) { where(:compute_resource_id => cr.id, :uuid => Array.wrap(vm).compact.map(&:identity).map(&:to_s)) }

  scope :with_compute_resource, -> { where.not(:compute_resource_id => nil, :uuid => nil) }

  # audit the changes to this model
  audited :except => [:last_report, :last_compile, :lookup_value_matcher]
  has_associated_audits
  #redefine audits relation because of the type change (by default the relation will look for auditable_type = 'Host::Managed')
  has_many :audits, -> { where(:auditable_type => 'Host') }, :foreign_key => :auditable_id,
    :class_name => 'Audited::Audit'

  # some shortcuts
  alias_attribute :arch, :architecture

  validates :environment_id, :presence => true, :unless => Proc.new { |host| host.puppet_proxy_id.blank? }
  validates :organization_id, :presence => true, :if => Proc.new { |host| host.managed? && SETTINGS[:organizations_enabled] }
  validates :location_id,     :presence => true, :if => Proc.new { |host| host.managed? && SETTINGS[:locations_enabled] }

  if SETTINGS[:unattended]
    # handles all orchestration of smart proxies.
    include UnattendedHelper # which also includes Foreman::Renderer
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
                          :if => Proc.new { |host| host.managed && host.pxe_build? && build? }
    validates :ptable_id, :presence => {:message => N_("can't be blank unless a custom partition has been defined")},
                          :if => Proc.new { |host| host.managed && host.disk.empty? && !Foreman.in_rake? && host.pxe_build? && host.build? }
    validates :provision_method, :inclusion => {:in => Proc.new { self.provision_methods }, :message => N_('is unknown')}, :if => Proc.new {|host| host.managed?}
    validates :medium_id, :presence => true, :if => Proc.new { |host| host.validate_media? }
    validate :provision_method_in_capabilities
    validate :short_name_periods
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

  def self.model_name
    ActiveModel::Name.new(Host)
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

  #retuns fqdn of host puppetmaster
  def pm_fqdn
    puppetmaster == "puppet" ? "puppet.#{domain.name}" : (puppetmaster).to_s
  end

  # Cleans Certificate and enable Autosign
  # Called before a host is given their provisioning template
  # Returns : Boolean status of the operation
  def handle_ca
    # If there's no puppetca, tell the caller that everything is ok
    return true unless Setting[:manage_puppetca]
    return true unless puppetca?

    # From here out, we expect things to work and return true
    return false unless respond_to?(:initialize_puppetca, true)
    return false unless initialize_puppetca
    return false unless delCertificate

    # If use_uuid_for_certificates is true, reuse the certname UUID value.
    # If false, then reset the certname if it does not match the hostname.
    if (Setting[:use_uuid_for_certificates] ? !Foreman.is_uuid?(certname) : certname != hostname)
      logger.info "Removing certificate value #{certname} for host #{name}"
      self.certname = nil
    end

    setAutosign
  end

  def import_facts(facts)
    # Facts come from 'existing' attributes/infrastructure. We skip triggering
    # the orchestration of this infrastructure when we create a host this way.
    skip_orchestration! if SETTINGS[:unattended]
    super(facts)
  ensure
    enable_orchestration! if SETTINGS[:unattended]
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

  # returns the host correct disk layout, custom or common
  def diskLayout
    @host = self
    template = disk.blank? ? ptable.layout : disk
    template_name = disk.blank? ? ptable.name : 'Custom disk layout'
    unattended_render(template.tr("\r", ''), template_name)
  end

  # reports methods
  def error_count
    %w[failed failed_restarts].sum {|f| status f}
  end

  def no_report
    last_report.nil? || last_report < Time.now.utc - (Setting[:puppet_interval] + Setting[:outofsync_interval]).minutes && enabled?
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

  def self.import_host(hostname, import_type, certname = nil, proxy_id = nil)
    raise(::Foreman::Exception.new("Invalid Hostname, must be a String")) unless hostname.is_a?(String)

    # downcase everything
    hostname.try(:downcase!)
    certname.try(:downcase!)

    host = Host.find_by_certname(certname) if certname.present?
    host ||= Host.find_by_name(hostname)
    host ||= Host.new(:name => hostname) # if no host was found, build a new one

    # if we were given a certname but found the Host by hostname we should update the certname
    # this also sets certname for newly created hosts
    host.certname = certname if certname.present?

    # if proxy authentication is enabled and we have no puppet proxy set and the upload came from puppet,
    # use it as puppet proxy.
    host.puppet_proxy_id ||= proxy_id if import_type == 'puppet'

    host
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

  def populate_fields_from_facts(facts = self.facts_hash, type = 'puppet')
    importer = super
    if Setting[:update_environment_from_facts]
      set_non_empty_values importer, [:environment]
    else
      self.environment ||= importer.environment unless importer.environment.blank?
    end
    operatingsystem.architectures << architecture if operatingsystem && architecture && !operatingsystem.architectures.include?(architecture)
    self.save(:validate => false)
  end

  # Called by build link in the list
  # Build is set
  # The boot link and autosign entry are created
  # Any existing puppet certificates are deleted
  # Any facts are discarded
  def setBuild
    self.build = true
    self.save
    errors.empty?
  end

  # this method accepts a puppets external node yaml output and generate a node in our setup
  # it is assumed that you already have the node (e.g. imported by one of the rack tasks)
  def importNode(nodeinfo)
    myklasses= []
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
    nodeinfo["parameters"].each_pair do |param,value|
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
    data.each do |k,v|
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
    #Puppetclass.find(counter.keys.compact)...
    association.camelize.constantize.find(counter.keys.compact).map {|i| {:label=>i.to_label, :data =>counter[i.id]}}
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
    Nic::Managed.rebuild_methods.values + Host::Managed.rebuild_methods.values
  end

  def classes_from_storeconfigs
    klasses = resources.select(:title).where(:restype => "Class").where("title <> ? AND title <> ?", "main", "Settings").order(:title)
    klasses.map!(&:title).delete(:main)
    klasses
  end

  def can_be_built?
    managed? && SETTINGS[:unattended] && pxe_build? && !build?
  end

  def hostgroup_inherited_attributes
    %w{puppet_proxy_id puppet_ca_proxy_id environment_id compute_profile_id realm_id}
  end

  def apply_inherited_attributes(attributes, initialized = true)
    return nil unless attributes
    #convert possible strong parameters to unsafe hash (filtering out unsafe items) and
    #clone to minimize side effects
    attributes = hash_clone(attributes.to_h).with_indifferent_access

    new_hostgroup_id = attributes['hostgroup_id'] || attributes['hostgroup_name'] || attributes['hostgroup'].try(:id)
    #hostgroup didn't change, no inheritance needs update.
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
      inherited_attrs.concat(%w{operatingsystem_id architecture_id})
      inherited_attrs << "subnet_id" unless compute_provides?(:ip)
      inherited_attrs << "subnet6_id" unless compute_provides?(:ip6)
      inherited_attrs.concat(%w{medium_id ptable_id pxe_loader}) if pxe_build?
    end
    inherited_attrs
  end

  def set_compute_attributes
    return unless compute_profile_present?
    self.compute_attributes = compute_resource.compute_profile_attributes_for(compute_profile_id)
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
    read_attribute(:certname) || name
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
    return read_attribute(:root_pass) if read_attribute(:root_pass).present?
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
    raise Foreman::Exception.new(
      _("No BMC NIC available for host %s") % self) unless bmc_available?
    bmc_proxy.boot({:function => 'bootdevice', :device => booting_device})
  end

  # take from hostgroup if compute_profile_id is nil
  def compute_profile_id
    read_attribute(:compute_profile_id) || hostgroup.try(:compute_profile_id)
  end

  def provision_method
    read_attribute(:provision_method) || capabilities.first.to_s
  end

  def explicit_pxe_loader
    read_attribute(:pxe_loader).presence
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
    managed && pxe_build? && build?
  end

  def render_template(template)
    @host = self
    load_template_vars
    unattended_render(template)
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

  def refresh_statuses
    HostStatus.status_registry.each do |status_class|
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
      raise ::Foreman::Exception.new(N_("There are orchestration modules with methods for configuration rebuild that have identical name: '%s'") % pretty_name) if result[pretty_name]
      result[pretty_name] = self.send method
    end
    result
  end

  def to_ip_address(name_or_ip)
    Foreman::Deprecation.deprecation_warning('1.17', 'Host::Managed#to_ip_address has been deprecated, you should use NicIpResolver class instead')
    NicIpResolver.new(:nic => provision_interface).to_ip_address(name_or_ip)
  end

  def apply_compute_profile(modification)
    modification.run(self, compute_resource.try(:compute_profile_for, compute_profile_id))
  end

  def firmware_type
    return unless pxe_loader.present?
    Operatingsystem.firmware_type(pxe_loader)
  end

  private

  def compute_profile_present?
    !(compute_profile_id.nil? || compute_resource_id.nil?)
  end

  def compute_attributes_empty?
    compute_attributes.nil? || compute_attributes.empty?
  end

  # validate uniqueness can't prevent saving two interfaces that has same DNS name
  # because the validation happens before transaction is committed, so data are not in DB
  # yet, this is the reason why we "reimplement" uniqueness validation
  def validate_dns_name_uniqueness
    dups = self.interfaces.select { |i| !i.marked_for_destruction? }.group_by { |i| [ i.name, i.domain_id ] }.detect { |dns, nics| dns.first.present? && nics.count > 1 }
    if dups.present?
      dups.last.first.errors.add(:name, :taken)
      self.errors.add :interfaces, _('Some interfaces are invalid')
      return false
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
    self.send("#{attr}=", value) if force || !send(attr).present?
  end

  # checks if the host association is a valid association for this host
  def ensure_associations
    status = true
    %w{ ptable medium architecture}.each do |e|
      value = self.send(e.to_sym)
      next if value.blank?
      unless os.send(e.pluralize.to_sym).include?(value)
        errors.add("#{e}_id".to_sym, _("%{value} does not belong to %{os} operating system") % { :value => value, :os => os })
        status = false
      end
    end if SETTINGS[:unattended] && managed? && os && pxe_build?

    puppetclasses.select("puppetclasses.id,puppetclasses.name").uniq.each do |e|
      unless environment.puppetclasses.map(&:id).include?(e.id)
        errors.add(:puppetclasses, _("%{e} does not belong to the %{environment} environment") % { :e => e, :environment => environment })
        status = false
      end
    end if environment
    status
  end

  def set_certname
    self.certname = Foreman.uuid if read_attribute(:certname).blank? || new_record?
  end

  def provision_method_in_capabilities
    return unless managed?
    errors.add(:provision_method, _('is an unsupported provisioning method')) unless capabilities.map(&:to_s).include?(self.provision_method)
  end

  def check_if_provision_method_changed
    if self.provision_method_changed?
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
    self.primary_interface.valid? unless self.primary_interface.changed?

    if self.primary_interface != self.provision_interface && !self.provision_interface.changed?
      self.provision_interface.valid?
    end
  end

  # For performance reasons logs and reports are deleted in batch
  # see http://projects.theforeman.org/issues/8316 for details
  def remove_reports
    return if reports.empty?
    Log.delete_all("report_id IN (#{reports.pluck(:id).join(',')})")
    Report.delete_all("host_id = #{id}")
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
end
