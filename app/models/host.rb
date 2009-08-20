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
  has_many :reports, :dependent => :destroy
  has_many :parameters, :dependent => :destroy

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
  validates_presence_of    :name, :architecture, :domain_id, :mac, :environment_id, :operatingsystem_id
  validates_length_of      :root_pass, :minimum => 8,:too_short => 'should be 8 characters or more'
  validates_format_of      :mac,       :with => /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/
  validates_format_of      :ip,        :with => /(\d{1,3}\.){3}\d{1,3}/
  validates_format_of      :sp_mac,    :with => /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/, :allow_nil => true, :allow_blank => true
  validates_format_of      :sp_ip,     :with => /(\d{1,3}\.){3}\d{1,3}/, :allow_nil => true, :allow_blank => true
  validates_format_of      :serial,    :with => /[01],\d{3,}n\d/, :message => "should follow this format: 0,9600n8", :allow_blank => true, :allow_nil => true
  validates_associated     :domain, :operatingsystem,  :architecture, :subnet,:media#, :user, :deployment, :model

  before_validation :normalize_addresses, :normalize_hostname

  # Returns the name of this host as a string
  # String: the host's name
  def to_label
    self.name
  end

  # Returns the name of this host as a string
  # String: the host's name
  def to_s
    self.to_label
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
    clearReports
    clearFacts
    save
    site_post_built = "#{$settings[:modulepath]}sites/#{self.domain.fullname.downcase}/built.sh"
      if File.executable? site_post_built
        %x{#{site_post_built} #{self.name} >> #{$settings[:logfile]} 2>&1 &}
      end
    # This can generate exceptions, so place it at the end of the sequence of operations
    #setAutosign
  end

  # no need to store anything in the db if the entry is plain "puppet"
  def puppetmaster
    self.read_attribute(:puppetmaster) || "puppet"
  end

  def puppetmaster=(pm)
    write_attribute(:puppetmaster, pm == "puppet" ? nil : pm)
  end

  # no need to store anything in the db if the password is our default
  def root_pass
    self.read_attribute(:root_pass) || "my default password"
  end

  # make sure we store an encrypted copy of the password in the database
  # this password can be use as is in a unix system
  def root_pass=(pass)
    p = pass =~ /^$1$gni$.*/ ? pass : pass.crypt("$1$gni$")
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
    (self.puppet_status & 0x00000fff)
  end

  def skipped
    (self.puppet_status & 0x00fff000) >> 12
  end

  def failed_restarts
    (self.puppet_status & 0x3f000000) >> 24
  end

  def no_report
    (self.puppet_status & 0x40000000) >> 30
  end

  def puppetclasses_names
    self.puppetclasses.collect {|c| c.name}
  end


  # provide information about each node, mainly used for puppet external nodes
  # TODO: remove hard coded default parameters into some selectable values in the database.
  def info
    # Static parameters
    param = {}
    param["puppetmaster"] = self.puppetmaster
    param["domainname"] = self.domain.fullname unless self.domain.fullname.empty?
    param.update self.params
    return Hash['classes' => self.puppetclasses_names, 'parameters' => param]
  end

  def params
    parameters = {}
    self.parameters.each do |p|
      parameters.update Hash[p.name => p.value]
    end
    return parameters
  end



  # import host facts, required when running without storeconfigs.
  # expect a yaml stream
  def importFacts yaml
    facts = YAML::load yaml
    if self.last_compile.nil? or facts.values[:_timestamp].to_date > self.last_compile.to_date
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
        logger.warn "Failed to save #{self.name}: #{self.errors.full_messages}"
        $stderr.puts $!
      end
    end
  end

  def populateFieldsFromFacts
    begin
    self.mac = self.fact(:macaddress)[0].value
    self.ip = self.fact(:ipaddress)[0].value if self.ip.nil?
    self.domain = Domain.find_or_create_by_name self.fact(:domain)[0].value
    # On solaris architecture fact is harwareisa
    arch=fact(:architecture)[0] || fact(:hardwareisa)[0]
    self.arch=Architecture.find_or_create_by_name arch.value
    # by default, puppet doesnt store an env name in the database
    env=fact(:environment)[0] || "production"
    self.environment = Environment.find_or_create_by_name env.value

    os_name = fact(:operatingsystem)[0].value
    os_rel = fact(:lsbdistrelease)[0].value || fact(:operatingsystemrelease)[0].value
    self.os = Operatingsystem.find_or_create_by_name_and_major os_name, os_rel
    self.save
    rescue
      logger.warn "failed to save #{self.name}: #{self.errors.full_messages}"
      $stderr.puts $!
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
  # this is done to ensure compatability with puppet storeconfigs
  # if the user added a domain, and the domain doesnt exist, we add it dynamiclly.
  def normalize_hostname
    # no hostname was given, since this is before validation we need to ignore it and let the validations to produce an error
    unless self.name.empty?
      if  self.name.count(".") == 0
        self.name = self.name + "." + self.domain.name unless self.domain.nil?
      else
        self.domain = Domain.find_or_create_by_name self.name.split(".")[1..-1].join(".") if self.domain.nil?
      end
    end
  end

end
