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

  # some shortcuts
  alias_attribute :os, :operatingsystem
  alias_attribute :arch, :architecture
  alias_attribute :hostname, :name

  validates_uniqueness_of  :ip
  validates_uniqueness_of  :mac
  validates_uniqueness_of  :sp_mac, :allow_nil => true, :allow_blank => true
  validates_uniqueness_of  :sp_name, :sp_ip, :allow_blank => true, :allow_nil => true
  validates_uniqueness_of  :name
  validates_format_of      :sp_name, :with => /.*-sp/, :allow_nil => true, :allow_blank => true
  validates_presence_of    :name, :architecture_id, :domain_id, :mac, :environment_id, :operatingsystem_id
  validates_length_of      :root_pass, :minimum => 8,:too_short => 'should be 8 characters or more'
  validates_format_of      :mac,       :with => /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/
  validates_format_of      :ip,        :with => /(\d{1,3}\.){3}\d{1,3}/
  validates_presence_of    :ptable, :message => "Cant be blank unless a custom partition has been defined", :if => Proc.new { |host| host.disk.empty? and not defined?(Rake) }
  validates_format_of      :sp_mac,    :with => /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/, :allow_nil => true, :allow_blank => true
  validates_format_of      :sp_ip,     :with => /(\d{1,3}\.){3}\d{1,3}/, :allow_nil => true, :allow_blank => true
  validates_format_of      :serial,    :with => /[01],\d{3,}n\d/, :message => "should follow this format: 0,9600n8", :allow_blank => true, :allow_nil => true
  validates_associated     :domain, :operatingsystem,  :architecture, :subnet,:media#, :user, :deployment, :model

  before_validation :normalize_addresses, :normalize_hostname

  # Returns the name of this host as a string
  # String: the host's name
  def to_label
    name
  end

  # Returns the name of this host as a string
  # String: the host's name
  def to_s
    to_label
  end

  def shortname
    domain.nil? ? name : name.chomp("." + domain.name)
  end

  def clearReports
    # Remove any reports that may be held against this host
    self.reports.each{|report| report.destroy}
  end

  def clearFacts
    self.fact_values.each {|fv| fv.destroy}
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
    read_attribute(:puppetmaster) || "puppet"
  end

  def puppetmaster=(pm)
    write_attribute(:puppetmaster, pm == "puppet" ? nil : pm)
  end

  # no need to store anything in the db if the password is our default
  def root_pass
    read_attribute(:root_pass) || $settings[:root_pass] || "!*!*!*!*!"
  end

  # make sure we store an encrypted copy of the password in the database
  # this password can be use as is in a unix system
  def root_pass=(pass)
    p = pass =~ /^$1$torque$.*/ ? pass : pass.crypt("$1$torque$")
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
    (puppet_status & 0x40000000) >> 30
  end

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
    param["puppetmaster"] = puppetmaster
    param["domainname"] = domain.fullname unless domain.fullname.empty?
    param.update self.params
    return Hash['classes' => self.puppetclasses_names, 'parameters' => param]
  end

  def params
    parameters = {}
    # read group parameters
    hostgroup.group_parameters.each {|p| parameters.update Hash[p.name => p.value] }
    # and now read host parameters, override if required
    host_parameters.each {|p| parameters.update Hash[p.name => p.value] }
    return parameters
  end

  # import host facts, required when running without storeconfigs.
  # expect a yaml stream
  def importFacts yaml
    facts = YAML::load yaml
    if last_compile.nil? or facts.values[:_timestamp].to_date > last_compile.to_date
      self.last_compile = facts.values[:_timestamp]
      # save all other facts
      if self.respond_to?("merge_facts")
        self.merge_facts(facts.values)
        # pre 0.24 it was called setfacts
      else
        self.setfacts(facts.values)
      end
      # we are saving here with no validations, as we really don't have most of the info required
      # but it should be fixed when parsing the facts
      begin
        self.save_with_validation(perform_validation = false)
        self.populateFieldsFromFacts
      rescue
        logger.warn "Failed to save #{name}: #{errors.full_messages.join(", ")}"
        $stderr.puts $!
      end
    end
  end

  def fv name
    unless fact(name).is_a?(Array) and not fact(name)[0].nil?
      logger.warn "found an empty fact value for #{name}!"
      nil
    else
      self.fact(name)[0].value
    end
  end

  def populateFieldsFromFacts
    self.mac = fv(:macaddress)
    self.ip = fv(:ipaddress) if ip.nil?
    self.domain = Domain.find_or_create_by_name fv(:domain)
    # On solaris architecture fact is harwareisa
    myarch=fv(:architecture) || fv(:hardwareisa)
    self.arch=Architecture.find_or_create_by_name myarch unless myarch.empty?
    # by default, puppet doesnt store an env name in the database
    env=fv(:environment) || "production"
    self.environment = Environment.find_or_create_by_name env

    os_name = fv(:operatingsystem)
    orel = fv(:lsbdistrelease) || fv(:operatingsystemrelease)
    major, minor = orel.split(".")
    self.os = Operatingsystem.find_or_create_by_name_and_major_and_minor os_name, major, minor
    self.save
  end

  # Called by build link in the list
  # Build is set
  # The boot link and autosign entry are created
  # Any existing puppet certificates are deleted
  # Any facts are discarded
  def setBuild
    begin
      self.build = true
      clearFacts
      clearReports
      #TODO move this stuff to be in the observor, as if the host changes after its being built this might invalidate the current settings
      GW::Puppetca.clean name
      GW::Tftp.create([mac, os.to_s.gsub(" ","-"), arch.name, serial])
      self.save
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
