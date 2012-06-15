require 'facts_importer'

class Host < Puppet::Rails::Host
  include Authorization
  include ReportCommon
  belongs_to :model
  has_many :host_classes, :dependent => :destroy
  has_many :puppetclasses, :through => :host_classes
  belongs_to :hostgroup
  has_many :reports, :dependent => :destroy
  has_many :host_parameters, :dependent => :destroy, :foreign_key => :reference_id
  accepts_nested_attributes_for :host_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  belongs_to :owner, :polymorphic => true
  belongs_to :sp_subnet, :class_name => "Subnet"
  belongs_to :compute_resource
  belongs_to :image

  include Hostext::Search
  include HostCommon

  class Jail < ::Safemode::Jail
    allow :name, :diskLayout, :puppetmaster, :puppet_ca_server, :operatingsystem, :os, :environment, :ptable, :hostgroup, :url_for_boot,
      :params, :info, :hostgroup, :compute_resource, :domain, :ip, :mac, :shortname, :architecture, :model, :certname, :capabilities,
      :provider
  end

  attr_reader :cached_host_params, :cached_lookup_keys_params

  scope :recent,      lambda { |*args| {:conditions => ["last_report > ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago)]} }
  scope :out_of_sync, lambda { |*args| {:conditions => ["last_report < ? and enabled != ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago), false]} }

  scope :with_fact, lambda { |fact,value|
    if fact.nil? or value.nil?
      raise "invalid fact"
    else
      { :joins  => "INNER JOIN fact_values fv_#{fact} ON fv_#{fact}.host_id = hosts.id
                   INNER JOIN fact_names fn_#{fact}  ON fn_#{fact}.id      = fv_#{fact}.fact_name_id",
        :select => "DISTINCT hosts.name, hosts.id", :conditions =>
          ["fv_#{fact}.value = ? and fn_#{fact}.name = ? and fv_#{fact}.fact_name_id = fn_#{fact}.id", value, fact] }
    end
  }

  scope :with_class, lambda { |klass|
    if klass.nil?
      raise "invalid class"
    else
      { :joins => :puppetclasses, :select => "hosts.name", :conditions => { :puppetclasses => { :name => klass } } }
    end
  }

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
    domain_conditions            = sanitize_sql_for_conditions([" (hosts.domain_id in (?))",dms = (user.domains).map(&:id)])
    compute_resource_conditions  = sanitize_sql_for_conditions([" (hosts.compute_resource_id in (?))",(crs = user.compute_resources).map(&:id)])
    hostgroup_conditions         = sanitize_sql_for_conditions([" (hosts.hostgroup_id in (?))",(hgs = user.hostgroups).map(&:id)])

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
      conditions.sub!(/\s*\(\)\s*/, "")
      conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
      conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
    end
    {:conditions => conditions}
  }

  scope :completer_scope, lambda { my_hosts }

  scope :run_distribution, lambda { |fromtime,totime|
    if fromtime.nil? or totime.nil?
      raise "invalid timerange"
    else
      { :joins      => "INNER JOIN reports ON reports.host_id = hosts.id",
        :conditions => ["reports.reported_at BETWEEN ? AND ?", fromtime, totime] }
    end
  }

  # audit the changes to this model
  acts_as_audited :except => [:last_report, :puppet_status, :last_compile]
  has_associated_audits

  # some shortcuts
  alias_attribute :os, :operatingsystem
  alias_attribute :arch, :architecture
  alias_attribute :hostname, :name
  alias_attribute :fqdn, :name

  validates_uniqueness_of  :name
  validates_presence_of    :name, :environment_id
  validate :is_name_downcased?

  if SETTINGS[:unattended]
    # handles all orchestration of smart proxies.
    include Foreman::Renderer
    include Orchestration
    include HostTemplateHelpers

    validates_uniqueness_of  :ip, :if => Proc.new {|host| host.require_ip_validation?}
    validates_uniqueness_of  :mac, :unless => Proc.new { |host| host.hypervisor? or host.compute? or !host.managed }
    validates_uniqueness_of  :sp_mac, :allow_nil => true, :allow_blank => true
    validates_uniqueness_of  :sp_name, :sp_ip, :allow_blank => true, :allow_nil => true
    validates_presence_of    :architecture_id, :operatingsystem_id, :if => Proc.new {|host| host.managed}
    validates_presence_of    :domain_id
    validates_presence_of    :mac, :unless => Proc.new { |host| host.hypervisor? or host.compute? or !host.managed  }

    validates_length_of      :root_pass, :minimum => 8,:too_short => 'should be 8 characters or more'
    validates_format_of      :mac, :with => Net::Validations::MAC_REGEXP, :unless => Proc.new { |host| host.hypervisor_id or host.compute? or !host.managed }
    validates_format_of      :ip,        :with => Net::Validations::IP_REGEXP, :if => Proc.new { |host| host.require_ip_validation? }
    validates_presence_of    :ptable_id, :message => "cant be blank unless a custom partition has been defined",
      :if => Proc.new { |host| host.managed and host.disk.empty? and not defined?(Rake) and capabilities.include?(:build) }
    validates_format_of      :sp_mac,    :with => Net::Validations::MAC_REGEXP, :allow_nil => true, :allow_blank => true
    validates_format_of      :sp_ip,     :with => Net::Validations::IP_REGEXP, :allow_nil => true, :allow_blank => true
    validates_format_of      :serial,    :with => /[01],\d{3,}n\d/, :message => "should follow this format: 0,9600n8", :allow_blank => true, :allow_nil => true

    validates_presence_of :puppet_proxy_id, :if => Proc.new {|h| h.managed? } if SETTINGS[:unattended]
  end

  before_validation :set_hostgroup_defaults, :set_ip_address, :set_default_user, :normalize_addresses, :normalize_hostname
  after_validation :ensure_assoications
  before_validation :set_certname, :if => Proc.new {|h| h.managed? and Setting[:use_uuid_for_certificates] } if SETTINGS[:unattended]

  def to_param
    name
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

  # Called from the host build post install process to indicate that the base build has completed
  # Build is cleared and the boot link and autosign entries are removed
  # A site specific build script is called at this stage that can do site specific tasks
  def built(installed = true)
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
      respond_to?(:initialize_puppetca) && initialize_puppetca && delCertificate && setAutosign
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

    info_hash = {}
    info_hash['classes'] = self.puppetclasses_names
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

  def host_params
    return cached_host_params unless cached_host_params.blank?
    hp = {}
    # read common parameters
    CommonParameter.all.each {|p| hp.update Hash[p.name => p.value] }
    # read domain parameters
    domain.domain_parameters.each {|p| hp.update Hash[p.name => p.value] } unless domain.nil?
    # read OS parameters
    operatingsystem.os_parameters.each {|p| hp.update Hash[p.name => p.value] } unless operatingsystem.nil?
    # read group parameters only if a host belongs to a group
    hp.update hostgroup.parameters unless hostgroup.nil?
    # and now read host parameters, override if required
    host_parameters.each {|p| hp.update Hash[p.name => p.value] }
    @cached_host_params = hp
  end

  def lookup_keys_params
    return cached_lookup_keys_params unless cached_lookup_keys_params.blank?
    p = {}
    # lookup keys
    if Setting["Enable_Smart_Variables_in_ENC"]
      klasses  = puppetclasses.map(&:id)
      klasses += hostgroup.classes.map(&:id) if hostgroup
      LookupKey.all(:conditions => {:puppetclass_id =>klasses.flatten } ).each do |k|
        p[k.to_s] = k.value_for(self)
      end unless klasses.empty?
    end
    @cached_lookup_keys_params = p
  end

  def self.importHostAndFacts yaml
    facts = YAML::load yaml
    return false unless facts.is_a?(Puppet::Node::Facts)

    h = Host.find_by_certname facts.name
    h ||= Host.find_by_name facts.name
    h ||= Host.new :name => facts.name

    h.save(:validate => false) if h.new_record?
    h.importFacts(facts)
  end

  # import host facts, required when running without storeconfigs.
  # expect a Puppet::Node::Facts
  def importFacts facts
    raise "invalid Fact" unless facts.is_a?(Puppet::Node::Facts)

    # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
    raise "Host is pending for Build" if build
    time = facts.values[:_timestamp]
    time = time.to_time if time.is_a?(String)

    # we are not doing anything we already processed this fact (or a newer one)
    return true unless last_compile.nil? or (last_compile + 1.minute < time)

    self.last_compile = time
    # save all other facts - pre 0.25 it was called setfacts
    respond_to?("merge_facts") ? self.merge_facts(facts.values) : self.setfacts(facts.values)
    save(:validate => false)

    populateFieldsFromFacts(facts.values)

    # we are saving here with no validations, as we want this process to be as fast
    # as possible, assuming we already have all the right settings in Foreman.
    # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
    # TODO: if it was installed by Foreman and there is a mismatch,
    # we should probably send out an alert.
    return self.save(:validate => false)

  rescue Exception => e
    logger.warn "Failed to save #{facts.name}: #{e}"
  end

  def populateFieldsFromFacts facts = self.facts_hash
    importer = Facts::Importer.new facts

    set_non_empty_values importer, [:domain, :architecture, :operatingsystem, :model, :certname]
    set_non_empty_values importer, [:mac, :ip] unless Setting[:ignore_puppet_facts_for_provisioning]
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
        error =  "Failed to import #{klass} for #{name}: doesn't exists in our database - ignoring"
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
    output = {}
    count(:group => assocication).each do |k,v|
      begin
        output[k.to_label] = v unless v == 0
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
    output = {}
    Host.count(:include => association.pluralize, :group => "#{association}_id").to_a.each do |a|
      #Ugly Ugly Ugly - I guess I'm missing something basic here
      if a[0]
        label = eval(association.camelize).send("find",a[0].to_i).to_label
        output[label] = a[1]
      end
    end
    output
  end

  def resources_chart(timerange = 1.day.ago)
    data = {}
    data[:applied], data[:failed], data[:restarted], data[:failed_restarts], data[:skipped] = [],[],[],[],[]
    reports.recent(timerange).each do |r|
      data[:applied]         << [r.reported_at.to_i*1000, r.applied ]
      data[:failed]          << [r.reported_at.to_i*1000, r.failed ]
      data[:restarted]       << [r.reported_at.to_i*1000, r.restarted ]
      data[:failed_restarts] << [r.reported_at.to_i*1000, r.failed_restarts ]
      data[:skipped]         << [r.reported_at.to_i*1000, r.skipped ]
    end
    data
  end

  def runtime_chart(timerange = 1.day.ago)
    data = {}
    data[:config], data[:runtime] = [], []
    reports.recent(timerange).each do |r|
      data[:config]  << [r.reported_at.to_i*1000, r.config_retrieval]
      data[:runtime] << [r.reported_at.to_i*1000, r.runtime]
    end
    data
  end

  def classes_from_storeconfigs
    klasses = resources.all(:conditions => {:restype => "Class"}, :select => :title, :order => :title)
    klasses.map!(&:title).delete(:main)
    klasses
  end

  def can_be_build?
    managed? and SETTINGS[:unattended] and capabilities.include?(:build) ? build == false : false
  end

  def facts_hash
    hash = {}
    fact_values.all(:include => :fact_name).collect do |fact|
      hash[fact.fact_name.name] = fact.value
    end
    hash
  end

  def enforce_permissions operation
    if operation == "edit" and new_record?
      return true # We get called again with the operation being set to create
    end
    current = User.current
    if (operation == "edit") or operation == "destroy"
      if current.allowed_to?("#{operation}_hosts".to_sym)
        return true if Host.my_hosts(current).include? self
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
    errors.add :base, "You do not have permission to #{operation} this host"
    false
  end

  def sp_valid?
    !sp_name.empty? and !sp_ip.empty? and !sp_mac.empty?
  end

  def jumpstart?
    operatingsystem.family == "Solaris" and architecture.name =~/Sparc/i rescue false
  end

  def set_hostgroup_defaults
    return unless hostgroup
    assign_hostgroup_attributes(%w{environment domain puppet_proxy puppet_ca_proxy})
    if SETTINGS[:unattended] and (new_record? or managed?)
      assign_hostgroup_attributes(%w{operatingsystem medium architecture ptable root_pass subnet})
      assign_hostgroup_attributes(Vm::PROPERTIES) if hostgroup.hypervisor? and not compute_resource_id
    end
  end

  def set_ip_address
    self.ip ||= subnet.unused_ip if subnet if SETTINGS[:unattended] and (new_record? or managed?)
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
      errors.add(:base, "no puppet proxy defined - cant continue")
      logger.warn "unable to execute puppet run, no puppet proxies defined"
      return false
    end
    ProxyAPI::Puppet.new({:url => puppet_proxy.url}).run fqdn
  rescue => e
    errors.add(:base, "failed to execute puppetrun: #{e}")
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

  private
  # align common mac and ip address input
  def normalize_addresses
    # a helper for variable scoping
    helper = []
    [self.mac,self.sp_mac].each do |m|
      unless m.empty?
        m.downcase!
        if m=~/[a-f0-9]{12}/
          m = m.gsub(/(..)/){|mh| mh + ":"}[/.{17}/]
        elsif mac=~/([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/
          m = m.split(":").map{|nibble| "%02x" % ("0x" + nibble)}.join(":")
        end
      end
      helper << m
    end
    self.mac, self.sp_mac = helper

    helper = []
    [self.ip,self.sp_ip].each do |i|
      unless i.empty?
        i = i.split(".").map{|nibble| nibble.to_i}.join(".") if i=~/(\d{1,3}\.){3}\d{1,3}/
      end
      helper << i
    end
    self.ip, self.sp_ip = helper
  end

  # ensure that host name is fqdn
  # if the user inputted short name, the domain name will be appended
  # this is done to ensure compatibility with puppet storeconfigs
  def normalize_hostname
    # no hostname was given or a domain was selected, since this is before validation we need to ignore
    # it and let the validations to produce an error
    return if name.empty?

    if domain.nil? and name.match(/\./)
      # try to assign the domain automatically based on our existing domains from the host FQDN
      self.domain = Domain.all.select{|d| name.match(d.name)}.first rescue nil
    else
      # if our host is in short name, append the domain name
      if !new_record? and changed_attributes.keys.include? "domain_id"
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
  def ensure_assoications
    status = true
    %w{ ptable medium architecture}.each do |e|
      value = self.send(e.to_sym)
      next if value.blank?
      unless os.send(e.pluralize.to_sym).include?(value)
        errors.add("#{e}_id".to_sym, "#{value} does not belong to #{os} operating system")
        status = false
      end
    end if SETTINGS[:unattended] and managed? and os

    puppetclasses.uniq.each do |e|
      unless environment.puppetclasses.include?(e)
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

  def is_name_downcased?
    return unless name.present?
    errors.add(:name, "must be downcase") unless name == name.downcase
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

  def set_non_empty_values importer, methods
    methods.each do |attr|
      value = importer.send(attr)
      self.send("#{attr}=", value) unless value.blank?
    end
  end

  def set_default_user
    self.owner ||= User.current
  end

  def set_certname
    self.certname = Foreman.uuid if read_attribute(:certname).blank? or new_record?
  end

end
