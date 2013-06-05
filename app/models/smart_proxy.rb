class SmartProxy < ActiveRecord::Base
  include Authorization
  include Taxonomix

  attr_accessible :name, :url, :location_ids, :organization_ids
  EnsureNotUsedBy.new(:hosts, :hostgroups, :subnets, :domains, :puppet_ca_hosts, :puppet_ca_hostgroups)
  #TODO check if there is a way to look into the tftp_id too
  # maybe with a predefined sql
  has_and_belongs_to_many :features
  has_many :subnets,    :foreign_key => "dhcp_id"
  has_many :domains,    :foreign_key => "dns_id"
  has_many_hosts        :foreign_key => "puppet_proxy_id"
  has_many :hostgroups, :foreign_key => "puppet_proxy_id"
  has_many :puppet_ca_hosts, :class_name => "Host::Managed", :foreign_key => "puppet_ca_proxy_id"
  has_many :puppet_ca_hostgroups, :class_name => "Hostgroup", :foreign_key => "puppet_ca_proxy_id"
  URL_HOSTNAME_MATCH = %r{^(?:http|https):\/\/([^:\/]+)}
  validates_uniqueness_of :name
  validates_presence_of :name, :url
  validates_format_of :url, :with => URL_HOSTNAME_MATCH, :message => N_("is invalid - only  http://, https:// are allowed")
  validates_uniqueness_of :url, :message => N_("Only one declaration of a proxy is allowed")

  # There should be no problem with associating features before the proxy is saved as the whole operation is in a transaction
  before_save :sanitize_url, :associate_features

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("smart_proxies.name")
    end
  }

  scope :my_proxies, lambda {
    user = User.current
    conditions = user.admin? || user.allowed_to?({:controller => :smart_proxy, :action => :index}) ? {} : '1 = 0'
    where(conditions)
  }

  def self.name_map
    {
      "tftp"     => Feature.find_by_name("TFTP"),
      "bmc"      => Feature.find_by_name("BMC"),
      "dns"      => Feature.find_by_name("DNS"),
      "dhcp"     => Feature.find_by_name("DHCP"),
      "puppetca" => Feature.find_by_name("Puppet CA"),
      "puppet"   => Feature.find_by_name("Puppet")
    }
  end

  name_map.each {|f,v| scope "#{f}_proxies".to_sym, where(:features => {:name => v.try(:name)}).joins(:features) }

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

  def self.smart_proxy_ids_for(hosts)
    ids = []
    ids << hosts.joins(:subnet).pluck('DISTINCT subnets.dhcp_id')
    ids << hosts.joins(:subnet).pluck('DISTINCT subnets.tftp_id')
    ids << hosts.joins(:subnet).pluck('DISTINCT subnets.dns_id')
    ids << hosts.joins(:domain).pluck('DISTINCT domains.dns_id')
    ids << hosts.pluck('DISTINCT puppet_proxy_id')
    ids << hosts.pluck('DISTINCT puppet_ca_proxy_id')
    ids << hosts.joins(:hostgroup).pluck('DISTINCT hostgroups.puppet_proxy_id')
    ids << hosts.joins(:hostgroup).pluck('DISTINCT hostgroups.puppet_ca_proxy_id')
    # returned both 7, "7". need to convert to integer or there are duplicates
    ids.flatten.compact.map{|i| i.to_i}.uniq
  end

  def ping
    associate_features
    errors
  end

  private

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
      else
        errors.add :base, _("No features found on this proxy, please make sure you enable at least one feature")
      end
    rescue => e
      errors.add(:base, _("Unable to communicate with the proxy: %s") % e)
      errors.add(:base, _("Please check the proxy is configured and running on the host."))
    end
    features.any?
  end
end
