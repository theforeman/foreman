class Host::Managed < Host::Base
  include Authorization
  include ReportCommon
  include Hostext::Search

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

  has_one :token, :foreign_key => :host_id, :dependent => :destroy, :conditions => Proc.new {"expires >= '#{Time.now.utc.to_s(:db)}'"}

  has_many :lookup_values, :finder_sql => Proc.new { normalize_hostname; %Q{ SELECT lookup_values.* FROM lookup_values WHERE (lookup_values.match = 'fqdn=#{fqdn}') } }, :dependent => :destroy
  # See "def lookup_values_attributes=" under, for the implementation of accepts_nested_attributes_for :lookup_values
  accepts_nested_attributes_for :lookup_values

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
      :model, :certname, :capabilities, :provider, :subnet, :token, :location, :organization
  end

  attr_reader :cached_host_params

  default_scope lambda {
      org = Organization.current
      loc = Location.current
      conditions = {}
      conditions[:organization_id] = Array.wrap(org).map(&:id) if org
      conditions[:location_id]     = Array.wrap(loc).map(&:id) if loc
      where(conditions)
    }

  scope :recent,      lambda { |*args| {:conditions => ["last_report > ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago)]} }
  scope :out_of_sync, lambda { |*args| {:conditions => ["last_report < ? and enabled != ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago), false]} }

  scope :with_os, lambda { where('hosts.operatingsystem_id IS NOT NULL') }
  scope :no_location, lambda { where(:location_id => nil) }
  scope :no_organization, lambda { where(:organization_id => nil) }

  scope :with_error, { :conditions => "(puppet_status > 0) and
   ( ((puppet_status >> #{BIT_NUM*METRIC.index("failed")} & #{MAX}) != 0) or
    ((puppet_status >> #{BIT_NUM*METRIC.index("failed_restarts")} & #{MAX}) != 0) )"
  }

  scope :without_error, { :conditions =>
    "((puppet_status >> #{BIT_NUM*METRIC.index("failed")} & #{MAX}) = 0) and
     ((puppet_status >> #{BIT_NUM*METRIC.index("failed_restarts")} & #{MAX}) = 0)"
  }

  scope :with_changes, { :conditions => "(puppet_status > 0) and
    ( ((puppet_status >> #{BIT_NUM*METRIC.index("applied")} & #{MAX}) != 0) or
    ((puppet_status >> #{BIT_NUM*METRIC.index("restarted")} & #{MAX}) != 0) )"
  }

  scope :without_changes, { :conditions =>
    "((puppet_status >> #{BIT_NUM*METRIC.index("applied")} & #{MAX}) = 0) and
     ((puppet_status >> #{BIT_NUM*METRIC.index("restarted")} & #{MAX}) = 0)"
  }

  scope :with_pending_changes,    { :conditions =>
    "(puppet_status > 0) and ((puppet_status >> #{BIT_NUM*METRIC.index("pending")} & #{MAX}) != 0)" }
  scope :without_pending_changes, { :conditions =>
    "((puppet_status >> #{BIT_NUM*METRIC.index("pending")} & #{MAX}) = 0)" }

  scope :successful, lambda { without_changes.without_error.without_pending_changes}

  scope :alerts_disabled, {:conditions => ["enabled = ?", false] }

  scope :alerts_enabled, {:conditions => ["enabled = ?", true] }

  scope :my_hosts, lambda {
    user                 = User.current
    return { :conditions => "" } if user.admin? # Admin can see all hosts

    owner_conditions             = sanitize_sql_for_conditions(["((hosts.owner_id in (?) AND hosts.owner_type = 'Usergroup') OR (hosts.owner_id = ? AND hosts.owner_type = 'User'))", user.my_usergroups.map(&:id), user.id])
    domain_conditions            = sanitize_sql_for_conditions([" (hosts.domain_id in (?))",dms = (user.domain_ids)])
    compute_resource_conditions  = sanitize_sql_for_conditions([" (hosts.compute_resource_id in (?))",(crs = user.compute_resource_ids)])
    hostgroup_conditions         = sanitize_sql_for_conditions([" (hosts.hostgroup_id in (?))",(hgs = user.hostgroup_ids)])
    organization_conditions      = sanitize_sql_for_conditions([" (hosts.organization_id in (?))",orgs = (user.organization_ids)])
    location_conditions          = sanitize_sql_for_conditions([" (hosts.location_id in (?))",locs = (user.location_ids)])

    fact_conditions = ""
    for user_fact in (ufs = user.user_facts)
      fact_conditions += sanitize_sql_for_conditions ["(hosts.id = fact_values.host_id and fact_values.fact_name_id = ? and fact_values.value #{user_fact.operator} ?)", user_fact.fact_name_id, user_fact.criteria]
      fact_conditions = user_fact.andor == "and" ? "(#{fact_conditions}) and " : "#{fact_conditions} or  "
    end
    if (match = fact_conditions.match(/^(.*).....$/))
      fact_conditions = "(#{match[1]})"
    end

    conditions = ""
    if user.filtering?
      conditions  = "#{owner_conditions}"                                                                                                                                 if     user.filter_on_owner
      (conditions = (user.domains_andor           == "and") ? "(#{conditions}) and #{domain_conditions} "           : "#{conditions} or #{domain_conditions} ")           unless dms.empty?
      (conditions = (user.compute_resources_andor == "and") ? "(#{conditions}) and #{compute_resource_conditions} " : "#{conditions} or #{compute_resource_conditions} ") unless crs.empty?
      (conditions = (user.hostgroups_andor        == "and") ? "(#{conditions}) and #{hostgroup_conditions} "        : "#{conditions} or #{hostgroup_conditions} ")        unless hgs.empty?
      (conditions = (user.facts_andor             == "and") ? "(#{conditions}) and #{fact_conditions} "             : "#{conditions} or #{fact_conditions} ")             unless ufs.empty?
      (conditions = (user.organizations_andor     == "and") ? "(#{conditions}) and #{organization_conditions} "     : "#{conditions} or #{organization_conditions} ")     unless orgs.empty?
      (conditions = (user.locations_andor         == "and") ? "(#{conditions}) and #{location_conditions} "         : "#{conditions} or #{location_conditions} ")         unless locs.empty?
      conditions.sub!(/\s*\(\)\s*/, "")
      conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
      conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
    end
    {:conditions => conditions}
  }

  scope :completer_scope, lambda { my_hosts }

  scope :run_distribution, lambda { |fromtime,totime|
    if fromtime.nil? or totime.nil?
      raise ::Foreman.Exception.new(N_("invalid time range"))
    else
      { :joins      => "INNER JOIN reports ON reports.host_id = hosts.id",
        :conditions => ["reports.reported_at BETWEEN ? AND ?", fromtime, totime] }
    end
  }

  scope :for_token, lambda { |token| joins(:token).where(:tokens => { :value => token }).select('hosts.*') }

  # audit the changes to this model
  audited :except => [:last_report, :puppet_status, :last_compile], :allow_mass_assignment => true
  has_associated_audits

  # some shortcuts
  alias_attribute :os, :operatingsystem
  alias_attribute :arch, :architecture
  alias_attribute :fqdn, :name

  validates_presence_of :environment_id

  if SETTINGS[:unattended]
    # handles all orchestration of smart proxies.
    include Foreman::Renderer
    include Orchestration
    include Orchestration::DHCP
    include Orchestration::DNS
    include Orchestration::Compute
    include Orchestration::TFTP
    include Orchestration::Puppetca
    include Orchestration::SSHProvision
    include HostTemplateHelpers

    validates_uniqueness_of  :ip, :if => Proc.new {|host| host.require_ip_validation?}
    validates_uniqueness_of  :mac, :unless => Proc.new { |host| host.compute? or !host.managed }
    validates_presence_of    :architecture_id, :operatingsystem_id, :if => Proc.new {|host| host.managed}
    validates_presence_of    :domain_id, :if => Proc.new {|host| host.managed}
    validates_presence_of    :mac, :unless => Proc.new { |host| host.compute? or !host.managed  }

    validates_length_of      :root_pass, :minimum => 8, :too_short => _('should be 8 characters or more')
    validates_format_of      :mac, :with => Net::Validations::MAC_REGEXP, :unless => Proc.new { |host| host.compute? or !host.managed }
    validates_format_of      :ip,        :with => Net::Validations::IP_REGEXP, :if => Proc.new { |host| host.require_ip_validation? }
    validates_presence_of    :ptable_id, :message => N_("cant be blank unless a custom partition has been defined"),
      :if => Proc.new { |host| host.managed and host.disk.empty? and not defined?(Rake) and capabilities.include?(:build) }
    validates_format_of      :serial,    :with => /[01],\d{3,}n\d/, :message => N_("should follow this format: 0,9600n8"), :allow_blank => true, :allow_nil => true

    validates_presence_of :puppet_proxy_id, :if => Proc.new {|h| h.managed? } if SETTINGS[:unattended]
  end

  before_validation :set_hostgroup_defaults, :set_ip_address, :set_default_user, :normalize_addresses, :normalize_hostname, :force_lookup_value_matcher
  after_validation :ensure_associations
  before_validation :set_certname, :if => Proc.new {|h| h.managed? and Setting[:use_uuid_for_certificates] } if SETTINGS[:unattended]

  # Replacement of accepts_nested_attributes_for :lookup_values,
  # to work around the lack of `host_id` column in lookup_values.
  def lookup_values_attributes= lookup_values_attributes
    lookup_values_attributes.each_value do |attribute|
      attr = attribute.dup
      if attr.has_key? :id
        lookup_value = lookup_values.find attr.delete(:id)
        if lookup_value
          mark_for_destruction = ActiveRecord::ConnectionAdapters::Column.value_to_boolean attr.delete(:_destroy)
          lookup_value.attributes = attr
          mark_for_destruction ? lookup_values.delete(lookup_value) : lookup_value.save!
        end
      elsif !ActiveRecord::ConnectionAdapters::Column.value_to_boolean attr.delete(:_destroy)
        lookup_values.build(attr)
      end
    end
  end

  def <=>(other)
    self.name <=> other.name
  end

  def shortname
    domain.nil? ? name : name.chomp("." + domain.name)
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
    oid = User.find(selection.to_i) if selection =~ (/-Users$/)
    oid = Usergroup.find(selection.to_i) if selection =~ (/-Usergroups$/)
    self.owner = oid
  end

  def clearReports
    # Remove any reports that may be held against this host
    Report.delete_all("host_id = #{id}")
  end

  def clearFacts
    FactValue.delete_all("host_id = #{id}")
  end

  def set_token
    return unless Setting[:token_duration] != 0
    self.create_token(:value => Foreman.uuid,
                      :expires => Time.now.utc + Setting[:token_duration].minutes)
  end

  def expire_tokens
    # this clean up other hosts as well, but reduce the need for another task to cleanup tokens.
    Token.delete_all(["expires < ? or host_id = ?", Time.now.utc.to_s(:db), id])
  end

  # Called from the host build post install process to indicate that the base build has completed
  # Build is cleared and the boot link and autosign entries are removed
  # A site specific build script is called at this stage that can do site specific tasks
  def built(installed = true)

    # delete all expired tokens
    self.build        = false
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
  # Called after a host is given their provisioning template
  # Returns : Boolean status of the operation
  def handle_ca
    return true if Rails.env == "test"
    return true unless Setting[:manage_puppetca]
    if puppetca?
      respond_to?(:initialize_puppetca,true) && initialize_puppetca && delCertificate && setAutosign
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

  # returns the list of puppetclasses a host is in.
  def puppetclasses_names
    all_puppetclasses.collect {|c| c.name}
  end

  def all_puppetclasses
    hostgroup.nil? ? puppetclasses : (hostgroup.classes + puppetclasses).uniq
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
    CommonParameter.all.each {|p| hp.update Hash[p.name => include_source ? {:value => p.value, :source => :common} : p.value] }
    # read domain parameters
    domain.domain_parameters.each {|p| hp.update Hash[p.name => include_source ? {:value => p.value, :source => :domain} : p.value] } unless domain.nil?
    # read OS parameters
    operatingsystem.os_parameters.each {|p| hp.update Hash[p.name => include_source ? {:value => p.value, :source => :os} : p.value] } unless operatingsystem.nil?
    # read group parameters only if a host belongs to a group
    hp.update hostgroup.parameters(include_source) unless hostgroup.nil?
    hp
  end

  def host_params
    return cached_host_params unless cached_host_params.blank?
    hp = host_inherited_params
    # and now read host parameters, override if required
    host_parameters.each {|p| hp.update Hash[p.name => p.value] }
    @cached_host_params = hp
  end

  def self.importHostAndFacts yaml
    facts = YAML::load yaml
    case facts
      when Puppet::Node::Facts
        certname = facts.values["certname"]
        name     = facts.values["fqdn"].downcase
        values   = facts.values
      when Hash
        certname = facts["certname"]
        name     = facts["fqdn"].downcase
        values   = facts
        return raise(::Foreman::Exception.new(N_("invalid facts hash"))) unless name and values
      else
        return raise(::Foreman::Exception.new(N_("Invalid Facts, much be a Puppet::Node::Facts or a Hash")))
    end

    if name == certname or certname.nil?
      h = Host.find_by_name name
    else
      h = Host.find_by_certname certname
      h ||= Host.find_by_name name
    end
    h ||= Host.new :name => name

    h.save(:validate => false) if h.new_record?
    h.importFacts(name, values)
  end

  def attributes_to_import_from_facts
    attrs = []
    attrs = [:mac, :ip] unless managed? and Setting[:ignore_puppet_facts_for_provisioning]
    super + [:domain, :architecture, :operatingsystem, :model, :certname] + attrs
  end

  def populateFieldsFromFacts facts = self.facts_hash
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
  def self.count_distribution assocication
    output = []
    count(:group => assocication).each do |k,v|
      begin
        output << {:label => k.to_label, :data => v }  unless v == 0
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
    counter = Host::Managed.joins(association.tableize.to_sym).group("#{association.tableize.to_sym}.id").count
    #Puppetclass.find(counter.keys.compact)...
    association.camelize.constantize.find(counter.keys.compact).map {|i| {:label=>i.to_label, :data =>counter[i.id]}}
  end

  def classes_from_storeconfigs
    klasses = resources.select(:title).where(:restype => "Class").where("title <> ? AND title <> ?", "main", "Settings").order(:title)
    klasses.map!(&:title).delete(:main)
    klasses
  end

  def can_be_built?
    managed? and SETTINGS[:unattended] and capabilities.include?(:build) ? build == false : false
  end

  def enforce_permissions operation
    if operation == "edit" and new_record?
      return true # We get called again with the operation being set to create
    end
    current = User.current
    if (operation == "edit") or operation == "destroy"
      if current.allowed_to?("#{operation}_hosts".to_sym)
        return true if Host.my_hosts.include? self
      end
    else # create
      if current.allowed_to?(:create_hosts)
        # We are unconstrained
        return true if current.domains.empty? and current.hostgroups.empty?
        # We are constrained and the constraint is matched
        return true if (!current.domains.empty?    and current.domains.include?(domain)) or
        (!current.hostgroups.empty? and current.hostgroups.include?(hostgroup))
      end
    end
    errors.add(:base, _("You do not have permission to %s this host") % operation)
    false
  end

  def jumpstart?
    operatingsystem.family == "Solaris" and architecture.name =~/Sparc/i rescue false
  end

  def set_hostgroup_defaults
    return unless hostgroup
    assign_hostgroup_attributes(%w{environment domain puppet_proxy puppet_ca_proxy})
    if SETTINGS[:unattended] and (new_record? or managed?)
      assign_hostgroup_attributes(%w{operatingsystem architecture})
      assign_hostgroup_attributes(%w{medium ptable subnet}) if capabilities.include?(:build)
    end
  end

  def set_ip_address
    self.ip ||= subnet.unused_ip if subnet and SETTINGS[:unattended] and (new_record? or managed?)
  end

  # returns a rundeck output
  def rundeck
    rdecktags = puppetclasses_names.map{|k| "class=#{k}"}
    unless self.params["rundeckfacts"].empty?
      rdecktags += self.params["rundeckfacts"].split(",").map{|rdf| "#{rdf}=#{fact(rdf)[0].value}"}
    end
    { name => { "description" => comment, "hostname" => name, "nodename" => name,
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
    managed? and !compute? or (compute? and !compute_resource.provided_attributes.keys.include?(:ip))
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
    compute_resource_id ? compute_resource.capabilities : [:build]
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
    read_attribute(:root_pass) || hostgroup.try(:root_pass) || Setting[:root_pass]
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

  def get_bmc_interface
    url       = SmartProxy.select { |f| f.features.map(&:name).include? "BMC" }.first.url
    interface = interfaces.select { |i| i.attrs[:provider] == "IPMI" }.first
    bmc       = ProxyAPI::BMC.new( { :host_ip => interface.ip,
                                     :url     => url,
                                     :user    => interface.username,
                                     :password => interface.password } )
  end

  def ipmi_power(action)
    get_bmc_interface.power(:action => action)
  end

  def ipmi_boot(booting_device)
    get_bmc_interface.boot({:function => 'bootdevice', :device => booting_device})
  end

  private

  def lookup_keys_params
    return {} unless Setting["Enable_Smart_Variables_in_ENC"]

    p = {}
    klasses = all_puppetclasses.map(&:id).flatten
    LookupKey.where(:puppetclass_id => klasses ).each do |k|
      p[k.to_s] = k.value_for(self)
    end unless klasses.empty?
    p
  end

  def lookup_keys_class_params
    Classification.new(:host => self).enc
  end

  def bmc_nic
    interfaces.bmc.first
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
      # if our host is in short name, append the domain name
      if !new_record? and changed_attributes['domain_id'].present?
        old_domain = Domain.find(changed_attributes["domain_id"])
        self.name.gsub(old_domain.to_s,"")
      end
      self.name += ".#{domain}" unless name =~ /.#{domain}$/i
    end
  end

  def assign_hostgroup_attributes attrs = []
    attrs.each do |attr|
      eval("self.#{attr.to_s} ||= hostgroup.#{attr.to_s}")
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
    end if SETTINGS[:unattended] and managed? and os and capabilities.include?(:build)

    puppetclasses.select("puppetclasses.id,puppetclasses.name").uniq.each do |e|
      unless environment.puppetclasses.map(&:id).include?(e.id)
        errors.add(:puppetclasses, "#{e} does not belong to the #{environment} environment")
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
    return dns_ptr_record.dns_lookup(name_or_ip).ip if dns_ptr_record
    # fall back to normal dns resolution
    domain.resolver.getaddress(name_or_ip).to_s
  end

  def set_default_user
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


end
