class SmartProxy < ActiveRecord::Base
  attr_accessible :name, :url
  #TODO check if there is a way to look into the tftp_id too
  # maybe with a perdefine sql
  has_and_belongs_to_many :features
  has_many :subnets,    :foreign_key => "dhcp_id"
  has_many :domains,    :foreign_key => "dns_id"
  has_many :hosts,      :foreign_key => "puppetproxy_id"
  has_many :hostgroups, :foreign_key => "puppetproxy_id"

  URL_HOSTNAME_MATCH = %r{^(?:http|https):\/\/([^:\/]+)}
  validates_uniqueness_of :name
  validates_presence_of :name, :url
  validates_format_of :url, :with => URL_HOSTNAME_MATCH, :message => "is invalid - only  http://, https:// are allowed"
  validates_uniqueness_of :url, :message => "Only one declaration of a proxy is allowed"

  # There should be no problem with associating features before the proxy is saved as the whole operation is in a transaction
  before_save :sanitize_url, :associate_features
  before_destroy EnsureNotUsedBy.new(:subnets, :domains, :hosts, :hostgroups)

  default_scope :order => 'LOWER(smart_proxies.name)'

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
      "puppet"   => Feature.find_by_name("Puppet")
    }
  end

  private

  def sanitize_url
    self.url.chomp!("/") unless url.empty?
  end

  def associate_features
    return true if Rails.env == "test"

    name_map = SmartProxy.name_map
    reason = false
    begin
      reply = ProxyAPI::Features.new(:url => url).features
      self.features = reply.map{|f| name_map[f]} if reply.is_a?(Array) and reply.any?
    rescue => e
      reason = e.message
    end
    unless reply
      errors.add :base, "Unable to communicate with the proxy: #{reason}"
      errors.add :base, "Please check the proxy is configured and running on the host before saving."
    end
    !reply.empty?
  end
end
