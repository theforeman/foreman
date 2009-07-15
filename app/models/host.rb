class Host < ActiveRecord::Base
#class Host < Puppet::Rails::Host

  validates_uniqueness_of  :ip
  validates_uniqueness_of  :mac
  validates_uniqueness_of  :sp_mac, :allow_nil => true, :allow_blank => true
  validates_uniqueness_of  :sp_hostname, :sp_ip, :allow_blank => true, :allow_nil => true
  validates_uniqueness_of  :hostname#, :if => :check_hostname?
  validates_length_of      :hostname, :within => 8..16
  validates_format_of      :hostname, :with => /^\w\w\w\w\w..*/
  validates_format_of      :sp_hostname, :with => /^\w\w\w\w\w..*-sp/, :allow_nil => true, :allow_blank => true
  validates_presence_of    :subnet,:hostname, :hostmode, :deployment, :puppetmaster, :media, :model, :puppetclass, :domain, :gi, :user, :architecture, :last_report
  validates_length_of      :root_pass, :minimum => 8,:too_short => 'should be 8 characters or more'
  validates_format_of      :mac,       :with => /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/
  validates_format_of      :ip,        :with => /(\d{1,3}\.){3}\d{1,3}/
  validates_format_of      :sp_mac,    :with => /([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/, :allow_nil => true, :allow_blank => true
  validates_format_of      :sp_ip,     :with => /(\d{1,3}\.){3}\d{1,3}/, :allow_nil => true, :allow_blank => true
  validates_format_of      :serial,    :with => /[01],\d{3,}n\d/, :message => "should follow this format: 0,9600n8", :allow_blank => true, :allow_nil => true
#  validates_associated     :domain, :gi,  :architecture, :model, :subnet,:media, :user, :deployment

  before_validation :normalize_addresses

  # Returns the name of this host as a string
  # String: the host's name
  def to_label
    self.hostname
  end

  # Returns the name of this host as a string
  # String: the host's name
  def to_s
    self.to_label
  end

  def cleanReports
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
    setBootLink
    clearReports
    clearFacts
    save
    site_post_built = "#{$settings[:modulepath]}sites/#{self.domain.fullname.downcase}/built.sh"
      if File.executable? site_post_built
        %x{#{site_post_built} #{self.hostname} >> #{$settings[:logfile]} 2>&1 &}
      end
    # This can generate exceptions, so place it at the end of the sequence of operations
    setAutosign
  end


  private
  
  # align common mac and ip address input
  def normalize_addresses
    [mac,sp_mac].each do |m|
      unless m.empty?
        m.downcase!
        if m=~/[a-f0-9]{12}/
          m = m.gsub(/(..)/){|mh| mh + ":"}[/.{17}/]
        elsif mac=~/([a-f0-9]{1,2}:){5}[a-f0-9]{1,2}/
          m = m.split(":").map{|nibble| "%02x" % ("0x" + nibble)}.join(":")
        end
      end
    end

    [ip,sp_ip].each do |i|
      unless ip.empty?
        i = self.ip.split(".").map{|nibble| nibble.to_i}.join(".") if i=~/(\d{1,3}\.){3}\d{1,3}/
      end
    end
  end

end
