class SmartProxy < ApplicationRecord
  audited
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  include Parameterizable::ByIdName

  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups, :subnets, :domains, [:puppet_ca_hosts, :hosts], [:puppet_ca_hostgroups, :hostgroups], :realms)
  # TODO check if there is a way to look into the tftp_id too
  # maybe with a predefined sql
  has_many :smart_proxy_features, :dependent => :destroy
  has_many :features, :through => :smart_proxy_features
  has_many :subnets,                                          :foreign_key => 'dhcp_id'
  has_many :domains,                                          :foreign_key => 'dns_id'
  has_many_hosts                                              :foreign_key => 'puppet_proxy_id'
  has_many :hostgroups,                                       :foreign_key => 'puppet_proxy_id'
  has_many :puppet_ca_hosts, :class_name => 'Host::Managed',  :foreign_key => 'puppet_ca_proxy_id'
  has_many :puppet_ca_hostgroups, :class_name => 'Hostgroup', :foreign_key => 'puppet_ca_proxy_id'
  has_many :realms,                                           :foreign_key => 'realm_proxy_id'
  validates :name, :uniqueness => true, :presence => true
  validates :url, :presence => true, :url_schema => ['http', 'https'],
    :uniqueness => { :message => N_('Only one declaration of a proxy is allowed') }

  # There should be no problem with associating features before the proxy is saved as the whole operation is in a transaction
  before_save :sanitize_url, :associate_features

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :url, :complete_value => :true
  scoped_search :relation => :features, :on => :name, :rename => :feature, :complete_value => :true

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order('smart_proxies.name')
    end
  }

  scope :with_features, ->(*feature_names) { where(:features => { :name => feature_names }).joins(:features) if feature_names.any? }

  def hostname
    URI(url).host
  end

  def to_s
    hostname
  end

  def hosts_count
    Host::Managed.search_for("smart_proxy = #{name}").count
  end

  def refresh
    statuses.values.each { |status| status.revoke_cache! }
    associate_features
    errors
  end

  def ping
    begin
      reply = get_features
      unless reply.is_a?(Hash)
        logger.debug("Invalid response from proxy #{name}: Expected Hash of features, got #{reply}.")
        errors.add(:base, _('An invalid response was received while requesting available features from this proxy'))
      end
    rescue => e
      errors.add(:base, _('Unable to communicate with the proxy: %s') % e)
    end
    !errors.any?
  end

  def taxonomy_foreign_conditions
    conditions = {}
    if has_feature?('Puppet') && has_feature?('Puppet CA')
      conditions = "puppet_proxy_id = #{id} OR puppet_ca_proxy_id = #{id}"
    elsif has_feature?('Puppet')
      conditions[:puppet_proxy_id] = id
    elsif has_feature?('Puppet CA')
      conditions[:puppet_ca_proxy_id] = id
    end
    conditions
  end

  def smart_proxy_feature_by_name(feature_name)
    feature_id = Feature.find_by(:name => feature_name).try(:id)
    # loop through the in memory object to work on unsaved objects
    smart_proxy_features.find { |spf| spf.feature_id == feature_id }
  end

  def has_feature?(feature_name)
    feature_ids = Feature.where(:name => feature_name).pluck(:id)
    smart_proxy_features.any? { |proxy_feature| feature_ids.include?(proxy_feature.feature_id) }
  end

  def capabilities(feature)
    smart_proxy_feature_by_name(feature).try(:capabilities)
  end

  def has_capability?(feature, capability)
    capabilities(feature)&.include?(capability.to_s)
  end

  def setting(feature, setting)
    smart_proxy_feature_by_name(feature).try(:settings).try(:[], setting)
  end

  def httpboot_http_port
    setting(:HTTPBoot, 'http_port')
  end

  def httpboot_http_port!
    httpboot_http_port || raise(::Foreman::Exception.new(N_("HTTP boot requires proxy with httpboot feature and http_port exposed setting")))
  end

  def httpboot_https_port
    setting(:HTTPBoot, 'https_port')
  end

  def httpboot_https_port!
    httpboot_https_port || raise(::Foreman::Exception.new(N_("HTTPS boot requires proxy with httpboot feature and https_port exposed setting")))
  end

  def statuses
    return @statuses if @statuses
    @statuses = {}
    features.each do |feature|
      name = feature.name.delete(' ')
      if (status = ProxyStatus.find_status_by_humanized_name(name))
        @statuses[name.downcase.to_sym] = status.new(self)
      end
    end
    @statuses[:version] = ProxyStatus::Version.new(self)

    @statuses
  end

  def feature_details
    smart_proxy_features.includes(:feature).each_with_object({}) do |smart_proxy_feature, hash|
      hash[smart_proxy_feature.feature.name] = smart_proxy_feature.details
    end
  end

  private

  def sanitize_url
    self.url = url.chomp('/') unless url.empty?
  end

  def associate_features
    begin
      reply = get_features
      unless reply.is_a?(Hash)
        logger.debug("Invalid response from proxy #{name}: Expected Hash or Array of features, got #{reply}.")
        errors.add(:base, _('An invalid response was received while requesting available features from this proxy'))
        throw :abort
      end

      feature_name_map = Feature.name_map
      valid_features = reply.select { |feature, options| feature_name_map.key?(feature) }

      if valid_features.any?
        SmartProxyFeature.import_features(self, valid_features)
      else
        smart_proxy_features.clear
        if reply.any?
          errors.add :base, _('Features "%s" in this proxy are not recognized by Foreman. '\
                              'If these features come from a Smart Proxy plugin, make sure Foreman has the plugin installed too.') % reply.keys.to_sentence
        else
          errors.add :base, _('No features found on this proxy, please make sure you enable at least one feature')
        end
      end
    rescue => e
      errors.add(:base, _('Unable to communicate with the proxy: %s') % e)
      errors.add(:base, _('Please check the proxy is configured and running on the host.'))
    end
    throw :abort if smart_proxy_features.empty?
  end

  def get_features
    begin
      reply = ProxyAPI::V2::Features.new(:url => url).features.with_indifferent_access
      reply.reject! { |name| reply[name]['state'] != 'running' }
    rescue NotImplementedError
      reply = ProxyAPI::Features.new(:url => url).features
    end

    if reply.is_a?(Array)
      Hash[reply.collect { |f| [f, {}] }]
    else
      reply
    end
  end

  apipie :class, desc: "A class representing #{model_name.human} object" do
    name 'Smart Proxy'
    refs 'SmartProxy'
    sections only: %w[all additional]
    prop_group :basic_model_props, ApplicationRecord, meta: { friendly_name: 'Smart Proxy' }
    property :hostname, String, desc: 'Returns name of the host with proxy'
    property :httpboot_http_port, Integer, desc: 'Returns proxy port for HTTP boot'
    property :httpboot_http_port!, Integer, desc: 'Same as httpboot_http_port, but raises Foreman::Exception if no port is set'
    property :httpboot_https_port, Integer, desc: 'Returns proxy port for HTTPS boot'
    property :httpboot_https_port!, Integer, desc: 'Same as httpboot_https_port, but raises Foreman::Exception if no port is set'
  end
  class Jail < ::Safemode::Jail
    allow :id, :name, :hostname, :httpboot_http_port, :httpboot_https_port, :httpboot_http_port!, :httpboot_https_port!
  end
end
