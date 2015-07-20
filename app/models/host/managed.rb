class Host::Managed < Host::Base
  include ReportCommon
  include Hostext::Search

  HostAspects.registry.values.each do |aspect_config|
    include aspect_config.extension_class if aspect_config.extension
  end

  PROVISION_METHODS = %w[build image]

  has_many :host_aspects, :foreign_key => :host_id, :inverse_of => :host
  accepts_nested_attributes_for :host_aspects

  belongs_to :hostgroup
  has_many :reports, :foreign_key => :host_id
  has_many :host_parameters, :dependent => :destroy, :foreign_key => :reference_id, :inverse_of => :host
  has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "HostParameter"
  accepts_nested_attributes_for :host_parameters, :allow_destroy => true
  include ParameterValidators
  belongs_to :owner, :polymorphic => true
  belongs_to :compute_resource
  belongs_to :image

  has_one :token, :foreign_key => :host_id, :dependent => :destroy
  before_destroy :remove_reports

  def self.complete_for(query, opts = {})
    matcher = /(\s*(?:(?:user\.[a-z]+)|owner)\s*[=~])\s*(\S*)\s*\z/
    matches = matcher.match(query)
    output = super(query, opts)
    if matches.present? && 'current_user'.starts_with?(matches[2])
      current_user_result = query.sub(matcher, '\1 current_user')
      output = [current_user_result] + output
    end
    output
  end

  # Define custom hook that can be called in model by magic methods (before, after, around)
  define_model_callbacks :build, :only => :after
  define_model_callbacks :provision, :only => :before

  # Custom hooks will be executed after_commit
  after_commit :build_hooks
  before_save :clear_data_on_build

  def build_hooks
    return unless respond_to?(:old) && old && (build? != old.build?)
    if build?
      run_callbacks :build do
        logger.debug { "custom hook after_build on #{name} will be executed if defined." }
      end
    else
      run_callbacks :provision do
        logger.debug { "custom hook before_provision on #{name} will be executed if defined." }
      end
    end
  end

  include HostCommon

  class Jail < ::Safemode::Jail
    allow :name, :diskLayout, :puppetmaster, :puppet_ca_server, :operatingsystem, :os, :environment, :ptable, :hostgroup,
      :url_for_boot, :params, :info, :hostgroup, :compute_resource, :domain, :ip, :mac, :shortname, :architecture,
      :model, :certname, :capabilities, :provider, :subnet, :token, :location, :organization, :provision_method,
      :image_build?, :pxe_build?, :otp, :realm, :param_true?, :param_false?, :nil?, :indent, :primary_interface,
      :provision_interface, :interfaces, :bond_interfaces, :interfaces_with_identifier, :managed_interfaces, :facts, :facts_hash, :root_pass,
      :sp_name, :sp_ip, :sp_mac, :sp_subnet
  end

  attr_reader :cached_host_params

  scope :recent,      lambda { |*args| {:conditions => ["last_report > ?", (args.first || (Setting[:puppet_interval] + Setting[:outofsync_interval]).minutes.ago)]} }
  scope :out_of_sync, lambda { |*args| {:conditions => ["last_report < ? and enabled != ?", (args.first || (Setting[:puppet_interval] + Setting[:outofsync_interval]).minutes.ago), false]} }

  scope :with_os, lambda { where('hosts.operatingsystem_id IS NOT NULL') }

  scope :with_error, lambda { where("(puppet_status > 0) and
   ( ((puppet_status >> #{BIT_NUM*METRIC.index("failed")} & #{MAX}) != 0) or
    ((puppet_status >> #{BIT_NUM*METRIC.index("failed_restarts")} & #{MAX}) != 0) )")
  }

  scope :without_error, lambda { where("((puppet_status >> #{BIT_NUM*METRIC.index("failed")} & #{MAX}) = 0) and
     ((puppet_status >> #{BIT_NUM*METRIC.index("failed_restarts")} & #{MAX}) = 0)")
  }

  scope :with_changes, lambda { where("(puppet_status > 0) and
    ( ((puppet_status >> #{BIT_NUM*METRIC.index("applied")} & #{MAX}) != 0) or
    ((puppet_status >> #{BIT_NUM*METRIC.index("restarted")} & #{MAX}) != 0) )")
  }

  scope :without_changes, lambda { where("((puppet_status >> #{BIT_NUM*METRIC.index("applied")} & #{MAX}) = 0) and
     ((puppet_status >> #{BIT_NUM*METRIC.index("restarted")} & #{MAX}) = 0)")
  }

  scope :with_pending_changes, lambda { where("(puppet_status > 0) and ((puppet_status >> #{BIT_NUM*METRIC.index("pending")} & #{MAX}) != 0)") }
  scope :without_pending_changes, lambda { where("((puppet_status >> #{BIT_NUM*METRIC.index("pending")} & #{MAX}) = 0)") }

  scope :successful, lambda { without_changes.without_error.without_pending_changes}

  scope :alerts_disabled, lambda { where(:enabled => false) }

  scope :alerts_enabled, lambda { where(:enabled => true) }

  scope :run_distribution, lambda { |fromtime,totime|
    if fromtime.nil? or totime.nil?
      raise ::Foreman.Exception.new(N_("invalid time range"))
    else
      joins("INNER JOIN reports ON reports.host_id = hosts.id").where("reports.reported_at BETWEEN ? AND ?", fromtime, totime)
    end
  }

  scope :for_token, lambda { |token| joins(:token).where(:tokens => { :value => token }).where("expires >= ?", Time.now.utc.to_s(:db)).select('hosts.*') }

  scope :for_vm, lambda { |cr,vm| where(:compute_resource_id => cr.id, :uuid => Array.wrap(vm).compact.map(&:identity)) }

  # audit the changes to this model
  audited :except => [:last_report, :puppet_status, :last_compile], :allow_mass_assignment => true
  has_associated_audits

  # some shortcuts
  alias_attribute :os, :operatingsystem
  alias_attribute :arch, :architecture

  validates :organization_id, :presence => true, :if => Proc.new {|host| host.managed? && SETTINGS[:organizations_enabled] }
  validates :location_id,     :presence => true, :if => Proc.new {|host| host.managed? && SETTINGS[:locations_enabled] }

  if SETTINGS[:unattended]
    # handles all orchestration of smart proxies.
    include Foreman::Renderer
    include Orchestration
    # DHCP orchestration delegation
    delegate :dhcp?, :dhcp_record, :to => :primary_interface
    # DNS orchestration delegation
    delegate :dns?, :reverse_dns?, :dns_a_record, :dns_ptr_record, :to => :primary_interface
    include Orchestration::Compute
    include Rails.application.routes.url_helpers
    # TFTP orchestration delegation
    delegate :tftp?, :tftp, :generate_pxe_template, :to => :provision_interface
    include Orchestration::Puppetca
    include Orchestration::SSHProvision
    include Orchestration::Realm
    include HostTemplateHelpers
    delegate :fqdn, :fqdn_changed?, :fqdn_was, :shortname, :to => :primary_interface,
             :allow_nil => true
    delegate :require_ip_validation?, :to => :provision_interface

    validates :architecture_id, :operatingsystem_id, :presence => true, :if => Proc.new {|host| host.managed}
    validates :root_pass, :length => {:minimum => 8, :message => _('should be 8 characters or more')},
                          :presence => {:message => N_('should not be blank - consider setting a global or host group default')},
                          :if => Proc.new { |host| host.managed && host.pxe_build? && build? }
    validates :ptable_id, :presence => {:message => N_("can't be blank unless a custom partition has been defined")},
                          :if => Proc.new { |host| host.managed and host.disk.empty? and not Foreman.in_rake? and host.pxe_build? and host.build? }
    validates :provision_method, :inclusion => {:in => PROVISION_METHODS, :message => N_('is unknown')}, :if => Proc.new {|host| host.managed?}
    validates :medium_id, :presence => true, :if => Proc.new { |host| host.validate_media? }
    validate :provision_method_in_capabilities
    validate :short_name_periods
    before_validation :set_compute_attributes, :on => :create
    validate :check_if_provision_method_changed, :on => :update, :if => Proc.new { |host| host.managed }
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
  after_validation :ensure_associations, :set_default_user
  before_validation :set_certname, :if => Proc.new {|h| h.managed? and Setting[:use_uuid_for_certificates] } if SETTINGS[:unattended]
  after_validation :trigger_nic_orchestration, :if => Proc.new { |h| h.managed? && h.changed? }, :on => :update
  before_validation :validate_dns_name_uniqueness

  def <=>(other)
    self.name <=> other.name
  end

  # method to return the correct owner list for host edit owner select dropbox
  def is_owned_by
    owner.id_and_type if owner
  end

  def self.model_name
    ActiveModel::Name.new(Host)
  end

  # virtual attributes which sets the owner based on the user selection
  # supports a simple user, or a usergroup
  # selection parameter is expected to be an ActiveRecord id_and_type method (see Foreman's AR extentions).
  def is_owned_by=(selection)
    oid = User.find(selection.to_i) if selection =~ (/-Users\Z/)
    oid = Usergroup.find(selection.to_i) if selection =~ (/-Usergroups\Z/)
    self.owner = oid
  end

  def clearReports
    # Remove any reports that may be held against this host
    Report.where("host_id = #{id}").delete_all
  end

  def clearFacts
    FactValue.where("host_id = #{id}").delete_all
  end

  def clear_data_on_build
    return unless respond_to?(:old) && old && build? && !old.build?
    clearFacts
    clearReports
  end

  def set_token
    return unless Setting[:token_duration] != 0
    self.build_token(:value => Foreman.uuid,
                     :expires => Time.now.utc + Setting[:token_duration].minutes)
  end

  def expire_token
    self.token.delete if self.token.present?
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
      recipients = owner ? owner.recipients_for(:host_built) : []
      MailNotification[:host_built].deliver(self, :users => recipients) if recipients.present?
      true
    else
      logger.warn "Failed to set Build on #{self}: #{self.errors.full_messages}"
      false
    end
  end

  #retuns fqdn of host puppetmaster
  def pm_fqdn
    raise "Old design"
  end

  # Cleans Certificate and enable Autosign
  # Called before a host is given their provisioning template
  # Returns : Boolean status of the operation
  def handle_ca
    raise "Old design"
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
    pxe_render(template.tr("\r", ''))
  end

  def configTemplate(args = {})
    Foreman::Deprecation.deprecation_warning("1.11", 'configTemplate was renamed to provisioning_template')
    self.provisioning_template(args)
  end

  # returns a configuration template (such as kickstart) to a given host
  def provisioning_template(opts = {})
    opts[:kind]               ||= "provision"
    opts[:operatingsystem_id] ||= operatingsystem_id
    opts[:hostgroup_id]       ||= hostgroup_id
    opts[:environment_id]     ||= puppet_aspect.environment_id if puppet_aspect

    ProvisioningTemplate.find_template opts
  end

  # reports methods

  def error_count
    %w[failed failed_restarts].sum {|f| status f}
  end

  def no_report
    last_report.nil? or last_report < Time.now - (Setting[:puppet_interval] + Setting[:outofsync_interval]).minutes and enabled?
  end

  def disabled?
    not enabled?
  end

  # the environment used by #clases nees to be self.environment and not self.parent.environment
  def parent_config_groups
    return [] unless hostgroup
    hostgroup.all_config_groups
  end

  # provide information about each node, mainly used for puppet external nodes
  # TODO: remove hard coded default parameters into some selectable values in the database.
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  def info
    # Static parameters
    param = {}
    # maybe these should be moved to the common parameters, leaving them in for now
    param["domainname"]   = domain.fullname unless domain.nil? or domain.fullname.nil?
    param["realm"]        = realm.name unless realm.nil?
    param["hostgroup"]    = hostgroup.to_label unless hostgroup.nil?
    if SETTINGS[:locations_enabled]
      param["location"] = location.name unless location.blank?
    end
    if SETTINGS[:organizations_enabled]
      param["organization"] = organization.name unless organization.blank?
    end
    if SETTINGS[:unattended]
      param["root_pw"]      = root_pass unless (!operatingsystem.nil? && operatingsystem.password_hash == 'Base64')
    end
    param["comment"]      = comment unless comment.blank?
    if SETTINGS[:login] and owner
      param["owner_name"]  = owner.name
      param["owner_email"] = owner.is_a?(User) ? owner.mail : owner.users.map(&:mail)
    end

    if Setting[:ignore_puppet_facts_for_provisioning]
      param["ip"]  = ip
      param["mac"] = mac
    end
    param['foreman_subnets'] = interfaces.map(&:subnet).compact.map(&:to_enc).uniq
    param['foreman_interfaces'] = interfaces.map(&:to_enc)
    param.update self.params

    # Parse ERB values contained in the parameters
    param = SafeRender.new(:variables => { :host => self }).parse(param)

    info_hash = {}
    info_hash['classes'] = []
    info_hash['parameters'] = param

    host_aspects.each do |aspect|
      aspect_hash = aspect.respond_to?(:info) ? aspect.info : {}
      info_hash.deep_merge! aspect_hash if aspect_hash
    end

    info_hash
  end

  def params
    host_params.update(lookup_keys_params)
  end

  def clear_host_parameters_cache!
    @cached_host_params = nil
  end

  def host_inherited_params(include_source = false)
    hp = {}
    # read common parameters
    CommonParameter.all.each {|p| hp.update Hash[p.name => include_source ? {:value => p.value, :source => N_('common').to_sym, :safe_value => p.safe_value} : p.value] }
    # read organization and location parameters
    hp.update organization.parameters(include_source) if SETTINGS[:organizations_enabled] && organization
    hp.update location.parameters(include_source)     if SETTINGS[:locations_enabled] && location
    # read domain parameters
    domain.domain_parameters.each {|p| hp.update Hash[p.name => include_source ? {:value => p.value, :source => N_('domain').to_sym, :safe_value => p.safe_value, :source_name => domain.name} : p.value] } unless domain.nil?
    # read OS parameters
    operatingsystem.os_parameters.each {|p| hp.update Hash[p.name => include_source ? {:value => p.value, :source => N_('os').to_sym, :safe_value => p.safe_value, :source_name => operatingsystem.to_label} : p.value] } unless operatingsystem.nil?
    # read group parameters only if a host belongs to a group
    hp.update hostgroup.parameters(include_source) if hostgroup
    hp
  end

  def host_params
    return cached_host_params unless cached_host_params.blank?
    hp = host_inherited_params
    # and now read host parameters, override if required
    host_parameters.each {|p| hp.update Hash[p.name => p.value] }
    @cached_host_params = hp
  end

  # JSON is auto-parsed by the API, so these should be in the right format
  def self.import_host_and_facts(hostname, facts, certname = nil, proxy_id = nil)
    raise(::Foreman::Exception.new("Invalid Facts, must be a Hash")) unless facts.is_a?(Hash)
    raise(::Foreman::Exception.new("Invalid Hostname, must be a String")) unless hostname.is_a?(String)

    # downcase everything
    hostname.try(:downcase!)
    certname.try(:downcase!)
    facts['domain'].try(:downcase!)

    host = certname.present? ? Host.find_by_certname(certname) : nil
    host ||= Host.find_by_name hostname
    host ||= Host.new(:name => hostname, :certname => certname) if Setting[:create_new_host_when_facts_are_uploaded]

    return Host.new, true if host.nil?
    # if we were given a certname but found the Host by hostname we should update the certname
    host.certname = certname if certname.present?

    # create relevant aspects here.
    unless host.puppet_aspect
      host.build_puppet_aspect
      config_aspect = host.host_aspects.build(:aspect_type => :configuration)
      config_aspect.execution_model = host.puppet_aspect
    end

    host.save(:validate => false) if host.new_record?
    state = host.import_facts(facts, proxy_id)
    [host, state]
  end

  def attributes_to_import_from_facts
    super + [:domain, :architecture, :operatingsystem]
  end

  def populate_fields_from_facts(facts = self.facts_hash, type = 'puppet', proxy_id = nil)
    importer = super

    host_aspects.each {|aspect| aspect.populate_fields_from_facts(importer, type, proxy_id)}

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

  # counts each association of a given host
  # e.g. how many hosts belongs to each os
  # returns sorted hash
  def self.count_distribution(association)
    output = []
    data = group("#{Host.table_name}.#{association}_id").reorder('').count
    associations = association.to_s.camelize.constantize.where(:id => data.keys).all
    data.each do |k,v|
      begin
        output << {:label => associations.detect {|a| a.id == k }.to_label, :data => v }  unless v == 0
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

  def classes_from_storeconfigs
    klasses = resources.select(:title).where(:restype => "Class").where("title <> ? AND title <> ?", "main", "Settings").order(:title)
    klasses.map!(&:title).delete(:main)
    klasses
  end

  def can_be_built?
    managed? and SETTINGS[:unattended] and pxe_build? and !build?
  end

  def jumpstart?
    operatingsystem.family == "Solaris" and architecture.name =~/Sparc/i rescue false
  end

  def set_hostgroup_defaults
    return unless hostgroup
    assign_hostgroup_attributes(%w{domain_id compute_profile_id})
    if SETTINGS[:unattended] and (new_record? or managed?)
      assign_hostgroup_attributes(%w{operatingsystem_id architecture_id realm_id})
      assign_hostgroup_attributes(%w{medium_id ptable_id subnet_id}) if pxe_build?
    end
  end

  def set_compute_attributes
    return unless compute_attributes.empty?
    return unless compute_profile_id && compute_resource_id
    self.compute_attributes = compute_resource.compute_profile_attributes_for(compute_profile_id)
  end

  def set_ip_address
    self.ip ||= subnet.unused_ip if subnet and SETTINGS[:unattended] and (new_record? or managed?)
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
    raise "Old design"
  end

  # if certname does not exist, use hostname instead
  def certname
    read_attribute(:certname) || name
  end

  def progress_report_id
    @progress_report_id ||= Foreman.uuid
  end

  def progress_report_id=(value)
    @progress_report_id = value
  end

  def capabilities
    compute_resource ? compute_resource.capabilities : [:build]
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

  def clone
    aspects = host_aspects.map do |aspect|
      assoc = Host.reflect_on_all_associations.find {|a| a.class_name == aspect.execution_model_type}
      assoc.name.to_sym
    end

    # do not copy system specific attributes
    host = self.deep_clone(:include => [:host_config_groups, :host_classes, :host_parameters, :host_aspects] + aspects,
                           :except  => [:name, :mac, :ip, :uuid, :certname, :last_report])
    self.interfaces.each do |nic|
      host.interfaces << nic.clone
    end
    if self.compute_resource
      host.compute_attributes = host.compute_resource.vm_compute_attributes_for(self.uuid)
    end

    host.host_aspects.each do |aspect|
      aspect.after_clone if aspect.respond_to? :after_clone
    end

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

  def host_status
    if build
      N_("Pending Installation")
    elsif respond_to?(:enabled) && !enabled
      N_("Alerts disabled")
    elsif respond_to?(:last_report) && last_report.nil?
      N_("No reports")
    elsif no_report
      N_("Out of sync")
    elsif error?
      N_("Error")
    elsif changes?
      N_("Active")
    elsif pending?
      N_("Pending")
    else
      N_("No changes")
    end
  end

  def smart_proxies
    SmartProxy.where(:id => smart_proxy_ids)
  end

  def smart_proxy_ids
    ids = []
    [subnet, hostgroup.try(:subnet)].compact.each do |s|
      ids << s.dhcp_id
      ids << s.tftp_id
      ids << s.dns_id
    end

    [domain, hostgroup.try(:domain)].compact.each do |d|
      ids << d.dns_id
    end

    [realm, hostgroup.try(:realm)].compact.each do |r|
      ids << r.realm_proxy_id
    end

    host_aspects.each do |aspect|
      aspect_ids = aspect.smart_proxy_ids if aspect.respond_to? :smart_proxy_ids
      ids += aspect_ids if aspect_ids
    end

    ids.uniq.compact
  end

  def bmc_proxy
    @bmc_proxy ||= bmc_nic.proxy
  end

  def bmc_available?
    ipmi = bmc_nic
    return false if ipmi.nil?
    ipmi.password.present? && ipmi.username.present? && ipmi.provider == 'IPMI'
  end

  def power
    opts = {:host => self}
    if compute_resource_id && uuid
      PowerManager::Virt.new(opts)
    elsif bmc_available?
      PowerManager::BMC.new(opts)
    else
      raise ::Foreman::Exception.new(N_("Unknown power management support - can't continue"))
    end
  end

  def ipmi_boot(booting_device)
    bmc_proxy.boot({:function => 'bootdevice', :device => booting_device})
  end

  # take from hostgroup if compute_profile_id is nil
  def compute_profile_id
    read_attribute(:compute_profile_id) || hostgroup.try(:compute_profile_id)
  end

  def provision_method
    read_attribute(:provision_method) || capabilities.first.to_s
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

  def available_template_kinds(provisioning = nil)
    kinds = if provisioning == 'image'
              cr     = ComputeResource.find_by_id(self.compute_resource_id)
              images = cr.try(:images)
              if images.blank?
                [TemplateKind.find('finish')]
              else
                uuid       = self.compute_attributes[cr.image_param_name]
                image_kind = images.find_by_uuid(uuid).try(:user_data) ? 'user_data' : 'finish'
                [TemplateKind.find(image_kind)]
              end
            else
              TemplateKind.all
            end

    kinds.map do |kind|
      filter = {
        :kind => kind.name,
        :operatingsystem_id => operatingsystem_id,
        :hostgroup_id       => hostgroup_id
      }
      template_filter_from_aspects(kind, filter)

      ProvisioningTemplate.find_template(filter)
    end.compact
  end

  def template_filter_from_aspects(kind, base_filter)
    HostAspects.registry.values.each do |aspect|
      val = self.send(aspect.name)
      base_filter.deep_merge!(val.template_filter_options(kind)) if val && val.respond_to?(:template_filter_options)
    end
    base_filter
  end

  def render_template(template)
    @host = self
    unattended_render(template)
  end

  def build_status
    build_status = HostBuildStatus.new(self)
    build_status.check_all_statuses
    build_status
  end

  # we must also clone interfaces objects so we can detect their attribute changes
  # method is public because it's used when we run orchestration from interface side
  def setup_clone
    return if new_record?
    @old = super { |clone| clone.interfaces = self.interfaces.map {|i| setup_object_clone(i) } }
  end

  def attributes
    hash = super

    # include all aspect attributes by default
    host_aspects.each do |aspect|
      assoc = Host.reflect_on_all_associations.find {|a| a.class_name == aspect.execution_model_type}
      obj = send(assoc.name)
      hash["#{assoc.name}_attributes"] = obj.attributes.reject { |key, _| ['id', 'created_at', 'updated_at'].include? key }
    end
    hash
  end

  private

  # validate uniqueness can't prevent saving two interfaces that has same DNS name
  # because the validation happens before transaction is committed, so data are not in DB
  # yet, this is the reason why we "reimplement" uniqueness validation
  def validate_dns_name_uniqueness
    dups = self.interfaces.group_by { |i| [ i.name, i.domain_id ] }.detect { |dns, nics| dns.first.present? && nics.count > 1 }
    if dups.present?
      dups.last.first.errors.add(:name, :taken)
      self.errors.add :interfaces, _('Some interfaces are invalid')
      return false
    end
  end

  def lookup_value_match
    "fqdn=#{fqdn || name}"
  end

  def lookup_keys_params
    return {} unless Setting["Enable_Smart_Variables_in_ENC"]
    Classification::GlobalParam.new(:host => self).enc
  end

  def assign_hostgroup_attributes(attrs = [])
    attrs.each do |attr|
      next if send(attr).to_i == -1
      value = hostgroup.send("inherited_#{attr}")
      self.send("#{attr}=", value) unless send(attr).present?
    end
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
    end if SETTINGS[:unattended] and managed? and os and pxe_build?
    status
  end

  # alias to ensure same method that resolves the last report between the hosts and reports tables.
  def reported_at
    last_report
  end

  # puppet report status table column name
  def self.report_status
    "puppet_status"
  end

  # converts a name into ip address using DNS.
  # if we are managing DNS, we can query the correct DNS server
  # otherwise, use normal systems dns settings to resolv
  def to_ip_address(name_or_ip)
    return name_or_ip if name_or_ip =~ Net::Validations::IP_REGEXP
    if dns_ptr_record
      lookup = dns_ptr_record.dns_lookup(name_or_ip)
      return lookup.ip unless lookup.nil?
    end
    # fall back to normal dns resolution
    domain.resolver.getaddress(name_or_ip).to_s
  rescue => e
    logger.warn "Unable to find IP address for '#{name_or_ip}': #{e}"
    raise ::Foreman::WrappedException.new(e, N_("Unable to find IP address for '%s'"), name_or_ip)
  end

  def set_default_user
    return if self.owner_type.present? && !OWNER_TYPES.include?(self.owner_type)
    self.owner_type ||= 'User'
    self.owner ||= User.current
  end

  def set_certname
    self.certname = Foreman.uuid if read_attribute(:certname).blank? or new_record?
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
    errors.add(:name, _("must not include periods")) if ( managed? && shortname && shortname.include?(".") && SETTINGS[:unattended] )
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
end
