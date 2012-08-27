class SmartProxy < ActiveRecord::Base
  ProxyFeatures = %w[ TFTP DNS DHCP Puppetca Puppet Squid ]
  attr_accessible :name, :url
  #TODO check if there is a way to look into the tftp_id too
  # maybe with a predefined sql
  has_and_belongs_to_many :features
  has_many :subnets,    :foreign_key => "dhcp_id"
  has_many :subnets,    :foreign_key => "squid_proxy_id"
  has_many :domains,    :foreign_key => "dns_id"
  has_many :hosts,      :foreign_key => "puppet_proxy_id"
  has_many :hostgroups, :foreign_key => "puppet_proxy_id"

  URL_HOSTNAME_MATCH = %r{^(?:http|https):\/\/([^:\/]+)}
  validates_uniqueness_of :name
  validates_presence_of :name, :url
  validates_format_of :url, :with => URL_HOSTNAME_MATCH, :message => "is invalid - only  http://, https:// are allowed"
  validates_uniqueness_of :url, :message => "Only one declaration of a proxy is allowed"

  # There should be no problem with associating features before the proxy is saved as the whole operation is in a transaction
  before_save :sanitize_url, :associate_features
  before_destroy EnsureNotUsedBy.new(:subnets, :domains, :hosts, :hostgroups)

  default_scope :order => 'LOWER(smart_proxies.name)'
  ProxyFeatures.each {|f| scope "#{f.downcase}_proxies".to_sym, where(:features => {:name => f}).joins(:features) }

  def hostname
    # This will always match as it is validated
    url.match(URL_HOSTNAME_MATCH)[1]
  end

  def to_s
    hostname =~ /^puppet\./ ? "puppet" : hostname
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def self.name_map
    {
      "tftp"     => Feature.find_by_name("TFTP"),
      "dns"      => Feature.find_by_name("DNS"),
      "dhcp"     => Feature.find_by_name("DHCP"),
      "puppetca" => Feature.find_by_name("Puppet CA"),
      "puppet"   => Feature.find_by_name("Puppet"),
      "squid"    => Feature.find_by_name("Squid")
    }
  end

  def warning
    @text
  end

  private

  def warning=(t)
    @text = t
  end

  def sanitize_url
    self.url.chomp!("/") unless url.empty?
  end

  def associate_features
    return true if Rails.env == "test"

    name_map = SmartProxy.name_map
    reason = false
    self.features.clear
    begin
      reply = ProxyAPI::Features.new(:url => url).features
      if reply.is_a?(Array) and reply.any?
        self.features = reply.map{|f| name_map[f]}

        # If it doesn't do the "Squid" feature, then it is
        # invalid as a squid_proxy_id. This should maybe be
        # done with a relationship somehow instead.
        if self.features.none? {|f| f.name == 'Squid'}
          subnets = Subnet.find(:all, :conditions => { :squid_proxy_id => self.id })
          if !subnets.empty?
            list = subnets.map { |s| s.name }.join(", ")
            self.warning = "This proxy no longer has the Squid feature, so it was removed from any subnets where it was the Squid proxy: #{list}"
            subnets.each do |subnet|
              subnet.squid_proxy_id = nil
              subnet.save
            end
          end
        end
      else
        errors.add :base, "No features found on this proxy, please make sure you enable at least one feature"
      end
    rescue => e
      errors.add :base, "Unable to communicate with the proxy: #{e}"
      errors.add :base, "Please check the proxy is configured and running on the host before saving."
    end
    features.any?
  end
end
