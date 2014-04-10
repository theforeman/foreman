class Host::Managed < Host::Base
  include ReportCommon
  include Hostext::Search

  PROVISION_METHODS = %w[build image]

  has_many :host_classes, :dependent => :destroy, :foreign_key => :host_id
  has_many :puppetclasses, :through => :host_classes
  belongs_to :hostgroup
  has_many :reports, :dependent => :destroy, :foreign_key => :host_id
  has_many :host_parameters, :dependent => :destroy, :foreign_key => :reference_id
  has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "HostParameter"
  accepts_nested_attributes_for :host_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  has_many :interfaces, :dependent => :destroy, :inverse_of => :host, :class_name => 'Nic::Base', :foreign_key => :host_id
  accepts_nested_attributes_for :interfaces, :reject_if => lambda { |a| a[:mac].blank? }, :allow_destroy => true
  belongs_to :owner, :polymorphic => true
  belongs_to :compute_resource
  belongs_to :image

  belongs_to :location
  belongs_to :organization

  has_one :token, :foreign_key => :host_id, :dependent => :destroy

  # Define custom hook that can be called in model by magic methods (before, after, around)
  define_model_callbacks :build, :only => :after
  define_model_callbacks :provision, :only => :before

  # Custom hooks will be executed after_commit
  after_commit :build_hooks

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
    allow :name, :diskLayout, :puppetmaster, :puppet_ca_server, :operatingsystem, :os, :environment, :ptable, :hostgroup, :location,
      :organization, :url_for_boot, :params, :info, :hostgroup, :compute_resource, :domain, :ip, :mac, :shortname, :architecture,
      :model, :certname, :capabilities, :provider, :subnet, :token, :location, :organization, :provision_method,
      :image_build?, :pxe_build?, :otp, :realm
  end

  attr_reader :cached_host_params

  default_scope lambda {
      org = Organization.current
      loc = Location.current
      conditions = {}
      conditions[:organization_id] = org.subtree_ids if org
      conditions[:location_id]     = loc.subtree_ids if loc
      where(conditions)
    }

  scope :recent,      lambda { |*args| {:conditions => ["last_report > ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago)]} }
  scope :out_of_sync, lambda { |*args| {:conditions => ["last_report < ? and enabled != ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago), false]} }

  scope :with_os, lambda { where('hosts.operatingsystem_id IS NOT NULL') }
  scope :no_location, lambda { where(:location_id => nil) }
  scope :no_organization, lambda { where(:organization_id => nil) }

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

  # audit the changes to this model
  audited :except => [:last_report, :puppet_status, :last_compile], :allow_mass_assignment => true
  has_associated_audits

  # some shortcuts
  alias_attribute :os, :operatingsystem
  alias_attribute :arch, :architecture

  validates :environment_id, :presence => true

  if SETTINGS[:unattended]
    # handles all orchestration of smart proxies.
    include Foreman::Renderer
    include Orchestration
    # Please note that the order of inclusion of DHCP and DNS orchestration modules is important,
    # as DHCP validation code relies on DNS code being run first (but it's being run in the opposite order atm)
    include Orchestration::DHCP
    include Orchestration::DNS
    include Orchestration::Compute
    include Orchestration::TFTP
    include Orchestration::Puppetca
    include Orchestration::SSHProvision
    include Orchestration::Realm
    include HostTemplateHelpers

    validates :ip, :uniqueness => true, :if => Proc.new {|host| host.require_ip_validation?}
    validates :mac, :uniqueness => true, :format => {:with => Net::Validations::MAC_REGEXP}, :unless => Proc.new { |host| host.compute? or !host.managed }
    validates :architecture_id, :operatingsystem_id, :domain_id, :presence => true, :if => Proc.new {|host| host.managed}
    validates :mac, :presence => true, :unless => Proc.new { |host| host.compute? or !host.managed }
    validates :root_pass, :length => {:minimum => 8, :message => _('should be 8 characters or more')},
                          :presence => {:message => N_('should not be blank - consider setting a global or host group default')},
                          :if => Proc.new { |host| host.managed && pxe_build? }
    validates :ip, :format => {:with => Net::Validations::IP_REGEXP}, :if => Proc.new { |host| host.require_ip_validation? }
    validates :ptable_id, :presence => {:message => N_("cant be blank unless a custom partition has been defined")},
                          :if => Proc.new { |host| host.managed and host.disk.empty? and not Foreman.in_rake? and pxe_build? }
    validates :serial, :format => {:with => /[01],\d{3,}n\d/, :message => N_("should follow this format: 0,9600n8")},
                       :allow_blank => true, :allow_nil => true
    validates :provision_method, :inclusion => {:in => PROVISION_METHODS, :message => N_('is unknown')}, :if => Proc.new {|host| host.managed?}
    validate :provision_method_in_capabilities
    after_validation :set_compute_attributes
  end

  before_validation :set_hostgroup_defaults, :set_ip_address, :normalize_addresses, :normalize_hostname, :force_lookup_value_matcher
  after_validation :ensure_associations, :set_default_user
  before_validation :set_certname, :if => Proc.new {|h| h.managed? and Setting[:use_uuid_for_certificates] } if SETTINGS[:unattended]

  def <=>(other)
    self.name <=> other.name
  end

  def shortname
    domain.nil? ? name : name.chomp("." + domain.name)
  end

  # we should guarantee the fqdn is always fully qualified
  def fqdn
    return name if name.blank? || ( !SETTINGS[:unattended] && domain.nil? )
    name.include?('.') ? name : "#{name}.#{domain}"
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

  def set_token
    return unless Setting[:token_duration] != 0
    self.create_token(:value => Foreman.uuid,
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
    self.save
  rescue => e
    logger.warn "Failed to set Build on #{self}: #{e}"
    false
  end

  #retuns fqdn of host puppetmaster
  def pm_fqdn
    puppetmaster == "puppet" ? "puppet.#{domain.name}" : "#{puppetmaster}"
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

    # If the user has changed use_uuid_for_certificates to false,
    # then null out the certname. This means we may revoke the hostname
    # or UUID but will only set autosign for the hostname.
    if !Setting[:use_uuid_for_certificates] && Foreman.is_uuid?(certname)
      logger.info "Removing UUID certificate value #{certname} for host #{name}"
      self.certname = nil
    end

    setAutosign
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
    pxe_render((disk.empty? ? ptable.layout : disk).gsub("\r",""))
  end

  # returns a configuration template (such as kickstart) to a given host
  def configTemplate opts = {}
    opts[:kind]               ||= "provision"
    opts[:operatingsystem_id] ||= operatingsystem_id
    opts[:hostgroup_id]       ||= hostgroup_id
    opts[:environment_id]     ||= environment_id

    ConfigTemplate.find_template opts
  end

  # reports methods

  def error_count
    %w[failed failed_restarts].sum {|f| status f}
  end

  def no_report
    last_report.nil? or last_report < Time.now - (Setting[:puppet_interval] + 3).minutes and enabled?
  end

  def disabled?
    not enabled?
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

  # provide information about each node, mainly used for puppet external nodes
  # TODO: remove hard coded default parameters into some selectable values in the database.
  def info
    # Static parameters
    param = {}
    # maybe these should be moved to the common parameters, leaving them in for now
    param["puppetmaster"] = puppetmaster
    param["domainname"]   = domain.fullname unless domain.nil? or domain.fullname.nil?
    param["hostgroup"]    = hostgroup.to_label unless hostgroup.nil?
    if SETTINGS[:locations_enabled]
      param["location"] = location.name unless location.blank?
    end
    if SETTINGS[:organizations_enabled]
      param["organization"] = organization.name unless organization.blank?
    end
    if SETTINGS[:unattended]
      param["root_pw"]      = root_pass
      param["puppet_ca"]    = puppet_ca_server if puppetca?
    end
    param["comment"]      = comment unless comment.blank?
    param["foreman_env"]  = environment.to_s unless environment.nil? or environment.name.nil?
    if SETTINGS[:login] and owner
      param["owner_name"]  = owner.name
      param["owner_email"] = owner.is_a?(User) ? owner.mail : owner.users.map(&:mail)
    end

    if Setting[:ignore_puppet_facts_for_provisioning]
      param["ip"]  = ip
      param["mac"] = mac
    end
    param.update self.params

    # Parse ERB values contained in the parameters
    param = SafeRender.new(:variables => { :host => self }).parse(param)

    classes = if Setting[:Parametrized_Classes_in_ENC] && Setting[:Enable_Smart_Variables_in_ENC]
                lookup_keys_class_params
              else
                self.puppetclasses_names
              end

    info_hash = {}
    info_hash['classes'] = classes
    info_hash['parameters'] = param
    info_hash['environment'] = param["foreman_env"] if Setting["enc_environment"]

    info_hash
  end

  def params
    host_params.update(lookup_keys_params)
  end

  def clear_host_parameters_cache!
    @cached_host_params = nil
  end

  def host_inherited_params include_source = false
    hp = {}
    # read common parameters
    CommonParameter.all.each {|p| hp.update Hash[p.name => include_source ? {:value => p.value, :source => N_('common').to_sym} : p.value] }
    # read organization and location parameters
    hp.update organization.parameters(include_source) if SETTINGS[:organizations_enabled] && organization
    hp.update location.parameters(include_source)     if SETTINGS[:locations_enabled] && location
    # read domain parameters
    domain.domain_parameters.each {|p| hp.update Hash[p.name => include_source ? {:value => p.value, :source => N_('domain').to_sym} : p.value] } unless domain.nil?
    # read OS parameters
    operatingsystem.os_parameters.each {|p| hp.update Hash[p.name => include_source ? {:value => p.value, :source => N_('os').to_sym} : p.value] } unless operatingsystem.nil?
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
  def self.import_host_and_facts hostname, facts, certname = nil, proxy_id = nil
    raise(::Foreman::Exception.new("Invalid Facts, must be a Hash")) unless facts.is_a?(Hash)
    raise(::Foreman::Exception.new("Invalid Hostname, must be a String")) unless hostname.is_a?(String)

    # downcase everything
    hostname.try(:downcase!)
    certname.try(:downcase!)

    host = certname.present? ? Host.find_by_certname(certname) : nil
    host ||= Host.find_by_name hostname
    host ||= Host.new(:name => hostname, :certname => certname) if Setting[:create_new_host_when_facts_are_uploaded]

    return Host.new, true if host.nil?
    # if we were given a certname but found the Host by hostname we should update the certname
    host.certname = certname if certname.present?

    # if proxy authentication is enabled and we have no puppet proxy set, use it.
    host.puppet_proxy_id ||= proxy_id

    host.save(:validate => false) if host.new_record?
    state = host.import_facts(facts)
    return host, state
  end

  def attributes_to_import_from_facts
    attrs = []
    attrs = [:mac, :ip] unless managed? and Setting[:ignore_puppet_facts_for_provisioning]
    super + [:domain, :architecture, :operatingsystem] + attrs
  end

  def populate_fields_from_facts facts = self.facts_hash
    importer = super
    normalize_addresses
    if Setting[:update_environment_from_facts]
      set_non_empty_values importer, [:environment]
    else
      self.environment ||= importer.environment unless importer.environment.blank?
    end

    self.save(:validate => false)
  end

  # Called by build link in the list
  # Build is set
  # The boot link and autosign entry are created
  # Any existing puppet certificates are deleted
  # Any facts are discarded
  def setBuild
    clearFacts
    clearReports

    self.build = true
    self.save
    errors.empty?
  end

  # this method accepts a puppets external node yaml output and generate a node in our setup
  # it is assumed that you already have the node (e.g. imported by one of the rack tasks)
  def importNode nodeinfo
    myklasses= []
    # puppet classes
    nodeinfo["classes"].each do |klass|
      if (pc = Puppetclass.find_by_name(klass))
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
      next if myparams.has_key?(param) and myparams[param] == value

      unless (hp = self.host_parameters.create(:name => param, :value => value))
        logger.warn "Failed to import #{param}/#{value} for #{name}: #{hp.errors.full_messages.join(", ")}"
        $stdout.puts $!
      end
    end

    self.save
  end

  # counts each association of a given host
  # e.g. how many hosts belongs to each os
  # returns sorted hash
  def self.count_distribution association
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
  def self.count_habtm association
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
    assign_hostgroup_attributes(%w{environment_id domain_id puppet_proxy_id puppet_ca_proxy_id compute_profile_id})
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

  # returns a rundeck output
  def rundeck
    rdecktags = puppetclasses_names.map{|k| "class=#{k}"}
    unless self.params["rundeckfacts"].empty?
      rdecktags += self.params["rundeckfacts"].gsub(/\s+/, '').split(',').map { |rdf| "#{rdf}=" + (facts_hash[rdf] || "undefined") }
    end
    { name => { "description" => comment, "hostname" => name, "nodename" => name,
      "Environment" => environment.name,
      "osArch" => arch.name, "osFamily" => os.family, "osName" => os.name,
      "osVersion" => os.release, "tags" => rdecktags, "username" => self.params["rundeckuser"] || "root" }
    }
  rescue => e
    logger.warn "Failed to fetch rundeck info for #{to_s}: #{e}"
    {}
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
    false
  end

  def overwrite?
    @overwrite ||= false
  end

  # We have to coerce the value back to boolean. It is not done for us by the framework.
  def overwrite=(value)
    @overwrite = value == "true"
  end

  def require_ip_validation?
    # if it's not managed there's nowhere to specify an IP anyway
    return false unless managed?
    # if the CR will provide an IP, then don't validate yet
    return false if compute_provides?(:ip)
    ip_for_dns     = (subnet.present? && subnet.dns_id.present?) || (domain.present? && domain.dns_id.present?)
    ip_for_dhcp    = subnet.present? && subnet.dhcp_id.present?
    ip_for_token   = Setting[:token_duration] == 0 && (pxe_build? || (image_build? && image.try(:user_data?)))
    # Any of these conditions will require an IP, so chain with OR
    ip_for_dns or ip_for_dhcp or ip_for_token
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
    read_attribute(:root_pass).blank? ? (hostgroup.try(:root_pass) || Setting[:root_pass]) : read_attribute(:root_pass)
  end

  def clone
    new = super
    new.puppetclasses = puppetclasses
    # Clone any parameters as well
    host_parameters.each{|param| new.host_parameters << HostParameter.new(:name => param.name, :value => param.value, :nested => true)}
    interfaces.each {|int| new.interfaces << int.clone }
    # clear up the system specific attributes
    [:name, :mac, :ip, :uuid, :certname, :last_report].each do |attr|
      new.send "#{attr}=", nil
    end
    new.puppet_status = 0
    new
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

    [puppet_proxy_id, puppet_ca_proxy_id, hostgroup.try(:puppet_proxy_id), hostgroup.try(:puppet_ca_proxy_id)].compact.each do |p|
      ids << p
    end
    ids.uniq.compact
  end

  def matching?
    missing_ids.empty?
  end

  def missing_ids
    Array.wrap(tax_location.try(:missing_ids)) + Array.wrap(tax_organization.try(:missing_ids))
  end

  def import_missing_ids
    tax_location.import_missing_ids     if location
    tax_organization.import_missing_ids if organization
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

  private

  def lookup_value_match
    "fqdn=#{fqdn}"
  end

  def lookup_keys_params
    return {} unless Setting["Enable_Smart_Variables_in_ENC"]
    Classification::GlobalParam.new(:host => self).enc
  end

  def lookup_keys_class_params
    Classification::ClassParam.new(:host => self).enc
  end

  # ensure that host name is fqdn
  # if the user inputted short name, the domain name will be appended
  # this is done to ensure compatibility with puppet storeconfigs
  def normalize_hostname
    # no hostname was given or a domain was selected, since this is before validation we need to ignore
    # it and let the validations to produce an error
    return if name.empty?

    # Remove whitespace
    self.name.gsub!(/\s/,'')

    if domain.nil? and name.match(/\./)
      # try to assign the domain automatically based on our existing domains from the host FQDN
      self.domain = Domain.all.select{|d| name.match(d.name)}.first rescue nil
    else
      # if we've just updated the domain name, strip off the old one
      if !new_record? and changed_attributes['domain_id'].present?
        old_domain = Domain.find(changed_attributes["domain_id"])
        self.name.chomp!("." + old_domain.to_s)
      end
      # name should be fqdn
      self.name = fqdn
    end
    # A managed host we should know the domain for; and the shortname shouldn't include a period
    # This only applies for unattended=true, as otherwise the name field includes the domain
    errors.add(:name, _("must not include periods")) if ( managed? && shortname.include?(".") && SETTINGS[:unattended] )
  end

  def assign_hostgroup_attributes attrs = []
    attrs.each do |attr|
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

    puppetclasses.select("puppetclasses.id,puppetclasses.name").uniq.each do |e|
      unless environment.puppetclasses.map(&:id).include?(e.id)
        errors.add(:puppetclasses, _("%{e} does not belong to the %{environment} environment") % { :e => e, :environment => environment })
        status = false
      end
    end if environment
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
  def to_ip_address name_or_ip
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

  def normalize_addresses
    self.mac = Net::Validations.normalize_mac(mac)
    self.ip  = Net::Validations.normalize_ip(ip)
  end

  def force_lookup_value_matcher
    lookup_values.each { |v| v.match = "fqdn=#{fqdn}" }
  end

  def tax_location
    return nil unless location_id
    @tax_location ||= TaxHost.new(location, self)
  end

  def tax_organization
    return nil unless organization_id
    @tax_organization ||= TaxHost.new(organization, self)
  end

  def provision_method_in_capabilities
    return unless managed?
    errors.add(:provision_method, _('is an unsupported provisioning method')) unless capabilities.map(&:to_s).include?(self.provision_method)
  end

end
