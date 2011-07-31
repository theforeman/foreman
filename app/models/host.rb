class Host < Puppet::Rails::Host
  include Authorization
  belongs_to :architecture
  belongs_to :medium
  belongs_to :model
  belongs_to :domain
  belongs_to :operatingsystem
  has_many :host_classes, :dependent => :destroy
  has_many :puppetclasses, :through => :host_classes
  belongs_to :environment
  belongs_to :subnet
  belongs_to :ptable
  belongs_to :hostgroup
  has_many :reports, :dependent => :destroy
  has_many :host_parameters, :dependent => :destroy, :foreign_key => :reference_id
  accepts_nested_attributes_for :host_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  belongs_to :owner, :polymorphic => true
  belongs_to :puppetproxy, :class_name => "SmartProxy"

  include Hostext::Search
  include HostCommon

  class Jail < Safemode::Jail
    allow :name, :diskLayout, :puppetmaster, :operatingsystem, :os, :environment, :ptable, :hostgroup, :url_for_boot,
        :params, :hostgroup, :domain, :ip, :mac
  end

  named_scope :recent,      lambda { |*args| {:conditions => ["last_report > ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago)]} }
  named_scope :out_of_sync, lambda { |*args| {:conditions => ["last_report < ? and enabled != ?", (args.first || (Setting[:puppet_interval] + 5).minutes.ago), false]} }

  named_scope :with_fact, lambda { |fact,value|
    unless fact.nil? or value.nil?
      { :joins => "INNER JOIN fact_values fv_#{fact} ON fv_#{fact}.host_id = hosts.id
                   INNER JOIN fact_names fn_#{fact}  ON fn_#{fact}.id      = fv_#{fact}.fact_name_id",
        :select => "DISTINCT hosts.name, hosts.id", :conditions =>
      ["fv_#{fact}.value = ? and fn_#{fact}.name = ? and fv_#{fact}.fact_name_id = fn_#{fact}.id",value, fact ] }
    else
      raise "invalid fact"
    end
  }

  named_scope :with_class, lambda { |klass|
    unless klass.nil?
      { :joins => :puppetclasses, :select => "hosts.name", :conditions => {:puppetclasses => {:name => klass }} }
    else
      raise "invalid class"
    end
  }

  named_scope :with, lambda { |*arg| { :conditions =>
    "(puppet_status >> #{Report::BIT_NUM*Report::METRIC.index(arg[0])} & #{Report::MAX}) > #{arg[1] || 0}"}
  }
  named_scope :with_error, { :conditions => "(puppet_status > 0) and
    ((puppet_status >> #{Report::BIT_NUM*Report::METRIC.index("failed")} & #{Report::MAX}) != 0) or
    ((puppet_status >> #{Report::BIT_NUM*Report::METRIC.index("failed_restarts")} & #{Report::MAX}) != 0)"
  }


  named_scope :with_changes, { :conditions => "(puppet_status > 0) and
    ((puppet_status >> #{Report::BIT_NUM*Report::METRIC.index("applied")} & #{Report::MAX}) != 0) or
    ((puppet_status >> #{Report::BIT_NUM*Report::METRIC.index("restarted")} & #{Report::MAX}) !=0)"
  }

  named_scope :successful, {:conditions => "puppet_status = 0"}
  named_scope :alerts_disabled, {:conditions => ["enabled = ?", false] }

  named_scope :my_hosts, lambda {
    user                 = User.current
    owner_conditions     = sanitize_sql_for_conditions(["((hosts.owner_id in (?) AND hosts.owner_type = 'Usergroup') OR (hosts.owner_id = ? AND hosts.owner_type = 'User'))", user.my_usergroups.map(&:id), user.id])
    domain_conditions    = sanitize_sql_for_conditions([" (hosts.domain_id in (?))",dms = (user.domains).map(&:id)])
    hostgroup_conditions = sanitize_sql_for_conditions([" (hosts.hostgroup_id in (?))",(hgs = user.hostgroups).map(&:id)])

    fact_conditions = ""
    for user_fact in (ufs = user.user_facts)
      fact_conditions += sanitize_sql_for_conditions ["(hosts.id = fact_values.host_id and fact_values.fact_name_id = ? and fact_values.value #{user_fact.operator} ?)", user_fact.fact_name_id, user_fact.criteria]
      fact_conditions = user_fact.andor == "and" ? "(#{fact_conditions}) and " : "#{fact_conditions} or  "
    end
    if match = fact_conditions.match(/^(.*).....$/)
      fact_conditions = "(#{match[1]})"
    end

    conditions = ""
    if user.filtering?
      conditions  = "#{owner_conditions}"                                                                                                            if     user.filter_on_owner
      (conditions = (user.domains_andor    == "and") ? "(#{conditions}) and #{domain_conditions} "    : "#{conditions} or #{domain_conditions} ")    unless dms.empty?
      (conditions = (user.hostgroups_andor == "and") ? "(#{conditions}) and #{hostgroup_conditions} " : "#{conditions} or #{hostgroup_conditions} ") unless hgs.empty?
      (conditions = (user.facts_andor      == "and") ? "(#{conditions}) and #{fact_conditions} "      : "#{conditions} or #{fact_conditions} ")      unless ufs.empty?
      conditions.sub!(/\s*\(\)\s*/, "")
      conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
      conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
    end
    {:conditions => conditions}
  }

  # audit the changes to this model
  acts_as_audited :except => [:last_report, :puppet_status, :last_compile]

  # some shortcuts
  alias_attribute :os, :operatingsystem
  alias_attribute :arch, :architecture
  alias_attribute :hostname, :name
  alias_attribute :fqdn, :name

  validates_uniqueness_of  :name
  validates_presence_of    :name, :environment_id
  if SETTINGS[:unattended].nil? or SETTINGS[:unattended]
    # handles all orchestration of smart proxies.
    include Foreman::Renderer
    include Orchestration
    include HostTemplateHelpers

    validates_uniqueness_of  :ip, :if => Proc.new {|host| host.managed}
    validates_uniqueness_of  :mac, :unless => Proc.new { |host| host.hypervisor? or !host.managed }
    validates_uniqueness_of  :sp_mac, :allow_nil => true, :allow_blank => true
    validates_uniqueness_of  :sp_name, :sp_ip, :allow_blank => true, :allow_nil => true
    validates_format_of      :sp_name, :with => /.*-sp/, :allow_nil => true, :allow_blank => true
    validates_presence_of    :architecture_id, :operatingsystem_id, :if => Proc.new {|host| host.managed}
    validates_presence_of    :domain_id
    validates_presence_of    :mac, :unless => Proc.new { |host| host.hypervisor? or !host.managed  }

    validates_length_of      :root_pass, :minimum => 8,:too_short => 'should be 8 characters or more'
    validates_format_of      :mac, :with => (/([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/), :unless => Proc.new { |host| host.hypervisor_id or !host.managed }
    validates_format_of      :ip,        :with => (/(\d{1,3}\.){3}\d{1,3}/), :if => Proc.new {|host| host.managed}
    validates_presence_of    :ptable, :message => "cant be blank unless a custom partition has been defined",
      :if => Proc.new { |host| host.managed and host.disk.empty? and not defined?(Rake)  }
    validates_format_of      :sp_mac,    :with => /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/, :allow_nil => true, :allow_blank => true
    validates_format_of      :sp_ip,     :with => /(\d{1,3}\.){3}\d{1,3}/, :allow_nil => true, :allow_blank => true
    validates_format_of      :serial,    :with => /[01],\d{3,}n\d/, :message => "should follow this format: 0,9600n8", :allow_blank => true, :allow_nil => true
  end

  before_validation :normalize_addresses, :normalize_hostname, :set_hostgroup_defaults
  after_validation :ensure_assoications

  def after_initialize
    self.owner ||= User.current
  end

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
    self.build = false
    self.installed_at = Time.now.utc if installed
    # If this save fails then an exception is raised and further actions are not processed
    unless Rails.env == "test"
      # Disallow any auto signing for our host.
      GW::Puppetca.disable name unless puppetca? or not Setting[:manage_puppetca]
      GW::Tftp.remove mac unless respond_to?(:tftp?) and tftp?
    end
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
    else
      # Legacy CA handling
      GW::Puppetca.clean(name) && GW::Puppetca.sign(name)
    end
  end

  # returns the host correct disk layout, custom or common
  def diskLayout
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

  def status(type = nil)
    raise "invalid type #{type}" if type and not Report::METRIC.include?(type)
    h = {}
    (type || Report::METRIC).each do |m|
      h[m] = (read_attribute(:puppet_status) || 0) >> (Report::BIT_NUM*Report::METRIC.index(m)) & Report::MAX
    end
    return type.nil? ? h : h[type]
  end

  # generate dynamically methods for all metrics
  # e.g. Report.last.applied
  Report::METRIC.each do |method|
    define_method method do
      status method
    end
  end

  def no_report
    last_report.nil? or last_report < Time.now - (Setting[:puppet_interval] + 3).minutes and enabled?
  end

  def disabled?
    not enabled?
  end

  # returns the list of puppetclasses a host is in.
  def puppetclasses_names
    return all_puppetclasses.collect {|c| c.name}
  end

  def all_puppetclasses
    return hostgroup.nil? ? puppetclasses : (hostgroup.classes + puppetclasses).uniq
  end

  # provide information about each node, mainly used for puppet external nodes
  # TODO: remove hard coded default parameters into some selectable values in the database.
  def info
    # Static parameters
    param = {}
    # maybe these should be moved to the common parameters, leaving them in for now
    param["puppetmaster"] = puppetmaster.to_s
    param["domainname"]   = domain.fullname unless domain.nil? or domain.fullname.nil?
    if Setting[:ignore_puppet_facts_for_provisioning]
      param["ip"]  = ip
      param["mac"] = mac
    end
    param.update self.params

    # lookup keys
    if Setting["Enable_Smart_Variables_in_ENC"]
      klasses  = puppetclasses.map(&:id)
      klasses += hostgroup.classes.map(&:id) if hostgroup
      LookupKey.all(:conditions => {:puppetclass_id =>klasses.flatten } ).each do |k|
        param[k.to_s] = k.value_for(self)
      end unless klasses.empty?
    end

    info_hash = {}
    info_hash['classes'] = self.puppetclasses_names
    info_hash['parameters'] = param
    info_hash['environment'] = environment.to_s unless environment.nil? or environment.name.nil?

    return info_hash
  end

  def params
    parameters = {}
    # read common parameters
    CommonParameter.all.each {|p| parameters.update Hash[p.name => p.value] }
    # read domain parameters
    domain.domain_parameters.each {|p| parameters.update Hash[p.name => p.value] } unless domain.nil?
    # read OS parameters
    operatingsystem.os_parameters.each {|p| parameters.update Hash[p.name => p.value] } unless operatingsystem.nil?
    # read group parameters only if a host belongs to a group
    parameters.update hostgroup.parameters unless hostgroup.nil?
    # and now read host parameters, override if required
    host_parameters.each {|p| parameters.update Hash[p.name => p.value] }
    return parameters
  end

  def self.importHostAndFacts yaml
    facts = YAML::load yaml
    return false unless facts.is_a?(Puppet::Node::Facts)

    h=find_or_create_by_name(facts.name)
    h.save(false) if h.new_record?
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
    save(false)

    # we want to import other information only if this host was never installed via Foreman
    populateFieldsFromFacts if installed_at.nil?

    # we are saving here with no validations, as we want this process to be as fast
    # as possible, assuming we already have all the right settings in Foreman.
    # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
    # TODO: if it was installed by Foreman and there is a mismatch,
    # we should probably send out an alert.
    return self.save(false)

  rescue Exception => e
    logger.warn "Failed to save #{facts.name}: #{e}"
  end

  def fv name
    v=fact_values.first(:select => "fact_values.value", :joins => :fact_name,
                        :conditions => "fact_names.name = '#{name}'")
    v.value unless v.nil?
  end

  def populateFieldsFromFacts
    unless Setting[:ignore_puppet_facts_for_provisioning]
      self.mac = fv(:macaddress).downcase unless fv(:macaddress).blank?
      self.ip = fv(:ipaddress) if ip.nil?
    end
    self.domain = Domain.find_or_create_by_name fv(:domain) unless fv(:domain).empty?
    # On solaris architecture fact is harwareisa
    if myarch=fv(:architecture) || fv(:hardwareisa)
      self.arch=Architecture.find_or_create_by_name myarch unless myarch.empty?
    end

    # by default, puppet doesn't store an env name in the database
    env = fv(:environment) || Setting[:default_puppet_environment]
    if Setting[:update_environment_from_facts]
      self.environment = Environment.find_or_create_by_name env
    else
      self.environment ||= Environment.find_or_create_by_name env
    end

    os_name = fv(:operatingsystem)
    if orel = fv(:lsbdistrelease) || fv(:operatingsystemrelease)
      major, minor = orel.split(".")
      minor ||= ""
      self.os = Operatingsystem.find_or_create_by_name_and_major_and_minor os_name, major, minor
    end

    unless self.model
      modelname = fv(:productname) || fv(:model) || (fv(:is_virtual) == "true" ? fv(:virtual) : nil)
      self.model = Model.find_or_create_by_name(modelname.strip) unless modelname.empty?
    end

    # again we are saving without validations as input is required (e.g. partition tables)
    self.save(false)
  end

  # Called by build link in the list
  # Build is set
  # The boot link and autosign entry are created
  # Any existing puppet certificates are deleted
  # Any facts are discarded
  def setBuild
    clearFacts
    clearReports

    # ensures that the legacy TFTP code is not called when using a smart proxy.
    unless respond_to?(:tftp?) and tftp?
      return false unless GW::Tftp.create([mac, os.to_s.gsub(" ","-"), arch.name, serial])
    end

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
      if pc = Puppetclass.find_by_name(klass)
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
  def self.count_habtm assocication
    output = {}
    Host.count(:include => assocication.pluralize, :group => "#{assocication}_id").to_a.each do |a|
      #Ugly Ugly Ugly - I guess I'm missing something basic here
      label = eval(assocication.camelize).send("find",a[0].to_i).to_label if a[0]
      output[label] = a[1]
    end
    output
  end

   def resources_chart(timerange = 1.day.ago)
    data = {}
    data[:applied], data[:failed], data[:restarted], data[:failed_restarts], data[:skipped] = [],[],[],[],[]
    reports.recent(timerange).each do |r|
      data[:applied]         << "[ #{r.reported_at.to_i}000, #{r.applied} ]"
      data[:failed]          << "[ #{r.reported_at.to_i}000, #{r.failed} ]"
      data[:restarted]       << "[ #{r.reported_at.to_i}000, #{r.restarted} ]"
      data[:failed_restarts] << "[ #{r.reported_at.to_i}000, #{r.failed_restarts} ]"
      data[:skipped]         << "[ #{r.reported_at.to_i}000, #{r.skipped} ]"
    end
    return data
  end

  def runtime_chart(timerange = 1.day.ago)
    data = {}
    data[:config], data[:runtime] = [], []
    reports.recent(timerange).each do |r|
      data[:config]  << "[ #{r.reported_at.to_i}000, #{r.config_retrieval} ]"
      data[:runtime] << "[ #{r.reported_at.to_i}000, #{r.runtime} ]"
    end
    return data
  end

  def classes_from_storeconfigs
    klasses = resources.all(:conditions => {:restype => "Class"}, :select => :title, :order => :title)
    klasses.map!(&:title).delete(:main)
    return klasses
  end

  def can_be_build?
    managed? and (SETTINGS[:unattended].nil? or SETTINGS[:unattended]) ? build == false : false
  end

  def facts_hash
    hash = {}
    fact_values.all(:include => :fact_name).collect do |fact|
      hash[fact.fact_name.name] = fact.value
      hash
    end
    return hash
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
    errors.add_to_base "You do not have permission to #{operation} this host"
    false
  end

  def sp_valid?
    !sp_name.empty? and !sp_ip.empty? and !sp_mac.empty?
  end

  def jumpstart?
    operatingsystem.family == "Solaris" and architecture.name =~/Sparc/i rescue false
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
  # if the user inputed short name, the domain name will be appended
  # this is done to ensure compatibility with puppet storeconfigs
  def normalize_hostname
    # no hostname was given or a domain was selected, since this is before validation we need to ignore
    # it and let the validations to produce an error
    return if name.empty?

    if domain.nil? and name.match(/\./)
      # try to assign the domain automaticilly based on our existing domains from the host FQDN
      self.domain = Domain.all.select{|d| name.match(d.name)}.first rescue nil
    else
      # if our host is in short name, append the domain name
      self.name += ".#{domain}" unless name =~ /.#{domain}$/i
    end
  end

  def set_hostgroup_defaults
    return unless hostgroup
    %w{environment operatingsystem medium architecture ptable root_pass puppetmaster_name puppetproxy}.each do |e|
      eval("self.#{e} = hostgroup.#{e}") if self.send(e.to_sym).nil?
    end
  end

  # checks if the host assoication is a valid assoication for this host
  def ensure_assoications
    status = true
    %w{ ptable medium architecture}.each do |e|
      value = self.send(e.to_sym)
      next if value.blank?
      unless os.send(e.pluralize.to_sym).include?(value)
        errors.add(e, "#{value} does not belong to #{os} operating system")
        status = false
      end
    end if os
    status
  end

end
