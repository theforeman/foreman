class Host < Puppet::Rails::Host
  belongs_to :architecture
  belongs_to :media
  belongs_to :model
  belongs_to :domain
  belongs_to :operatingsystem
  has_and_belongs_to_many :puppetclasses
  belongs_to :environment
  belongs_to :subnet
  belongs_to :ptable
  belongs_to :hostgroup
  has_many :reports, :dependent => :destroy
  has_many :host_parameters, :dependent => :destroy

  # audit the changes to this model
  acts_as_audited :except => [:last_report, :puppet_status, :last_compile]

  # some shortcuts
  alias_attribute :os, :operatingsystem
  alias_attribute :arch, :architecture
  alias_attribute :hostname, :name

  validates_uniqueness_of  :name
  validates_presence_of    :name, :environment_id
  if $settings[:unattended].nil? or $settings[:unattended]
    validates_uniqueness_of  :ip
    validates_uniqueness_of  :mac
    validates_uniqueness_of  :sp_mac, :allow_nil => true, :allow_blank => true
    validates_uniqueness_of  :sp_name, :sp_ip, :allow_blank => true, :allow_nil => true
    validates_format_of      :sp_name, :with => /.*-sp/, :allow_nil => true, :allow_blank => true
    validates_presence_of    :architecture_id, :domain_id, :mac, :operatingsystem_id
    validates_length_of      :root_pass, :minimum => 8,:too_short => 'should be 8 characters or more'
    validates_format_of      :mac,       :with => /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/
    validates_format_of      :ip,        :with => /(\d{1,3}\.){3}\d{1,3}/
    validates_presence_of    :ptable, :message => "Cant be blank unless a custom partition has been defined",
                             :if => Proc.new { |host| host.disk.empty? and not defined?(Rake) }
    validates_format_of      :sp_mac,    :with => /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/, :allow_nil => true, :allow_blank => true
    validates_format_of      :sp_ip,     :with => /(\d{1,3}\.){3}\d{1,3}/, :allow_nil => true, :allow_blank => true
    validates_format_of      :serial,    :with => /[01],\d{3,}n\d/, :message => "should follow this format: 0,9600n8", :allow_blank => true, :allow_nil => true
    validates_associated     :domain, :operatingsystem,  :architecture, :subnet,:media#, :user, :deployment, :model
  end

  before_validation :normalize_addresses, :normalize_hostname

  # Returns the name of this host as a string
  # String: the host's name
  def to_label
    name
  end

  def to_s
    to_label
  end

  def shortname
    domain.nil? ? name : name.chomp("." + domain.name)
  end

  def clearReports
    # Remove any reports that may be held against this host
    Report.delete_all("host_id = #{self.id}")
  end

  def clearFacts
    FactValue.delete_all("host_id = #{self.id}")
  end

  # Called from the host build post install process to indicate that the base build has completed
  # Build is cleared and the boot link and autosign entries are removed
  # A site specific build script is called at this stage that can do site specific tasks
  def built
    self.build = false
    self.installed_at = Time.now.utc
    # disallow any auto signing for our host.
    GW::Puppetca.disable self.name
    GW::Tftp.remove self.mac
    save
    site_post_built = "#{$settings[:modulepath]}sites/#{self.domain.name.downcase}/built.sh"
    if File.executable? site_post_built
      %x{#{site_post_built} #{self.name} >> #{$settings[:logfile]} 2>&1 &}
    end
  end

  # no need to store anything in the db if the entry is plain "puppet"
  def puppetmaster
    read_attribute(:puppetmaster) || $settings[:puppet_server] || "puppet"
  end

  def puppetmaster=(pm)
    write_attribute(:puppetmaster, pm == ($settings[:puppet_server] || "puppet") ? nil : pm)
  end

  #retuns fqdn of host puppetmaster
  def pm_fqdn
    puppetmaster == "puppet" ? "puppet.#{domain.name}" : "#{puppetmaster}"
  end

  # no need to store anything in the db if the password is our default
  def root_pass
    read_attribute(:root_pass) || $settings[:root_pass] || "!*!*!*!*!"
  end

  # make sure we store an encrypted copy of the password in the database
  # this password can be use as is in a unix system
  def root_pass=(pass)
    p = pass =~ /^$1$foreman$.*/ ? pass : pass.crypt("$1$foreman$")
    write_attribute(:root_pass, p)
  end

  # returns the host correct disk layout, custom or common
  def diskLayout
    disk.empty? ? ptable.layout : disk
  end

  # reports methods

  def error_count
    failed + skipped + failed_restarts
  end

  def failed
    (puppet_status & 0x00000fff)
  end

  def skipped
    (puppet_status & 0x00fff000) >> 12
  end

  def failed_restarts
    (puppet_status & 0x3f000000) >> 24
  end

  def no_report
    last_report.nil? or last_report < Time.now - 33.minutes
  end

  # returns the list of puppetclasses a host is in.
  def puppetclasses_names
    if hostgroup.nil?
      return puppetclasses.collect {|c| c.name}
    else
      return (hostgroup.puppetclasses.collect {|c| c.name} + puppetclasses.collect {|c| c.name}).uniq
    end
  end


  # provide information about each node, mainly used for puppet external nodes
  # TODO: remove hard coded default parameters into some selectable values in the database.
  def info
    # Static parameters
    param = {}
    # maybe these should be moved to the common parameters, leaving them in for now
    param["puppetmaster"] = puppetmaster
    param["domainname"] = domain.fullname unless domain.fullname.empty?
    param.update self.params
    return Hash['classes' => self.puppetclasses_names, 'parameters' => param, 'environment' => environment.to_s]
  end

  def params
    parameters = {}
    # read common parameters
    CommonParameter.find_each {|p| parameters.update Hash[p.name => p.value] }
    # read domain parameters
    domain.domain_parameters.each {|p| parameters.update Hash[p.name => p.value] }
    # read group parameters only if a host belongs to a group
    hostgroup.group_parameters.each {|p| parameters.update Hash[p.name => p.value] } unless hostgroup.nil?
    # and now read host parameters, override if required
    host_parameters.each {|p| parameters.update Hash[p.name => p.value] }
    return parameters
  end

  def self.importHostAndFacts yaml
    facts = YAML::load yaml
    raise "invalid Fact" unless facts.is_a?(Puppet::Node::Facts)

    h=Host.find_or_create_by_name facts.name
    return h.importFacts(facts)
  end

  # import host facts, required when running without storeconfigs.
  # expect a Puppet::Node::Facts
  def importFacts facts
    raise "invalid Fact" unless facts.is_a?(Puppet::Node::Facts)

    # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
    raise "Host is pending for Build" if build
    time = facts.values[:_timestamp]
    time = time.to_time if time.is_a?(String)
    if last_compile.nil? or (last_compile + 1.minute < time)
      self.last_compile = time
      begin
        # save all other facts
        if self.respond_to?("merge_facts")
          self.merge_facts(facts.values)
          # pre 0.25 it was called setfacts
        else
          self.setfacts(facts.values)
        end
        # we are saving here with no validations, as we want this process to be as fast
        # as possible, assuming we already have all the right settings in Foreman.
        # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
        # TODO: if it was installed by Foreman and there is a mismatch,
        # we should probably send out an alert.
        self.save_with_validation(perform_validation = false)

        # we want to import other information only if this host was never installed via Foreman
        installed_at.nil? ? self.populateFieldsFromFacts : true
      rescue
        logger.warn "Failed to save #{name}: #{errors.full_messages.join(", ")}"
        $stderr.puts $!
      end
    end
  end

  def fv name
    v=fact_values.find(:first, :select => "fact_values.value", :joins => :fact_name,
                       :conditions => "fact_names.name = '#{name}'")
    v.value unless v.nil?
  end

  def populateFieldsFromFacts
    self.mac = fv(:macaddress)
    self.ip = fv(:ipaddress) if ip.nil?
    self.domain = Domain.find_or_create_by_name fv(:domain)
    # On solaris architecture fact is harwareisa
    if myarch=fv(:architecture) || fv(:hardwareisa)
      self.arch=Architecture.find_or_create_by_name myarch
    end
    # by default, puppet doesnt store an env name in the database
    env=fv(:environment) || "production"
    self.environment = Environment.find_or_create_by_name env

    os_name = fv(:operatingsystem)
    if orel = fv(:lsbdistrelease) || fv(:operatingsystemrelease)
      major, minor = orel.split(".")
      self.os = Operatingsystem.find_or_create_by_name_and_major_and_minor os_name, major, minor
    end
    # again we are saving without validations as input is required (e.g. partition tables)
    self.save_with_validation(perform_validation = false)
  end

  # Called by build link in the list
  # Build is set
  # The boot link and autosign entry are created
  # Any existing puppet certificates are deleted
  # Any facts are discarded
  def setBuild
    clearFacts
    clearReports
    #TODO move this stuff to be in the observer, as if the host changes after its being built this might invalidate the current settings
    return false unless GW::Puppetca.clean name
    return false unless GW::Tftp.create([mac, os.to_s.gsub(" ","-"), arch.name, serial])
    self.build = true
    self.save
  end

  # this method accepts a puppets external node yaml output and generate a node in our setup
  # it is assumed that you already have the node (e.g. imported by one of the rack tasks)
  def importNode nodeinfo
    # puppet classes
    nodeinfo["classes"].each do |klass|
      if pc = Puppetclass.find_by_name(klass)
        self.puppetclasses << pc unless puppetclasses.exists?(pc)
      else
        logger.warn "Failed to import #{klass} for #{name}: doesn't exists in our database - ignoreing"
        $stderr.puts $!
      end
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
        $stderr.puts $!
      end
    end

    self.save
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
  # if they user inputed short name, the domain name will be appended
  # this is done to ensure compatibility with puppet storeconfigs
  # if the user added a domain, and the domain doesn't exist, we add it dynamically.
  def normalize_hostname
    # no hostname was given, since this is before validation we need to ignore it and let the validations to produce an error
    unless name.empty?
      if name.count(".") == 0
        self.name = name + "." + domain.name unless domain.nil?
      else
        self.domain = Domain.find_or_create_by_name name.split(".")[1..-1].join(".") if domain.nil?
      end
    end
  end

end
