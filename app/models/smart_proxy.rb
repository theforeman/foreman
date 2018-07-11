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
  has_and_belongs_to_many :features
  has_many :subnets,                                          :foreign_key => 'dhcp_id'
  has_many :domains,                                          :foreign_key => 'dns_id'
  has_and_belongs_to_many :pools, :join_table => :pools_smart_proxies, :class_name => 'SmartProxyPool'
  has_many_hosts :through => 'pools'
  has_many :hostgroups, :through => 'pools'
  has_many :puppet_ca_hosts, :class_name => 'Host::Managed', :through => 'pools'
  has_many :puppet_ca_hostgroups, :class_name => 'Hostgroup', :through => 'pools'
  has_many :realms,                                           :foreign_key => 'realm_proxy_id'
  validates :name, :uniqueness => true, :presence => true
  validates :url, :presence => true, :url_schema => ['http', 'https'],
    :uniqueness => { :message => N_('Only one declaration of a proxy is allowed') }

  # There should be no problem with associating features before the proxy is saved as the whole operation is in a transaction
  before_save :sanitize_url, :associate_features
  before_create :create_pool

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :url, :complete_value => :true
  scoped_search :relation => :pools, :on => :name, :rename => :pool, :complete_value => :true
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

  def port
    URI(url).port
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

  def taxonomy_foreign_conditions
    conditions = {}
    if has_feature?('Puppet') && has_feature?('Puppet CA')
      conditions = "puppet_proxy_pool_id = #{id} OR puppet_ca_proxy_pool_id = #{id}"
    elsif has_feature?('Puppet')
      conditions[:puppet_proxy_pool_id] = id
    elsif has_feature?('Puppet CA')
      conditions[:puppet_ca_proxy_pool_id] = id
    end
    conditions
  end

  def has_feature?(feature)
    self.features.any? { |proxy_feature| proxy_feature.name == feature }
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

  private

  def sanitize_url
    self.url = url.downcase.chomp('/') unless url.empty?
  end

  def create_pool
    spp = SmartProxyPool.create_with(name: self.name).find_or_initialize_by(hostname: self.hostname)
    self.pools << spp
    spp.locations = self.locations if SETTINGS[:locations_enabled]
    spp.organizations = self.organizations if SETTINGS[:organizations_enabled]
  end

  def associate_features
    begin
      reply = ProxyAPI::Features.new(:url => url).features
      unless reply.is_a?(Array)
        logger.debug("Invalid response from proxy #{name}: Expected Array of features, got #{reply}.")
        errors.add(:base, _('An invalid response was received while requesting available features from this proxy'))
        throw :abort
      end
      valid_features = reply.map{|f| Feature.name_map[f]}.compact
      if valid_features.any?
        self.features = Feature.where(:name => valid_features)
      else
        self.features.clear
        if reply.any?
          errors.add :base, _('Features "%s" in this proxy are not recognized by Foreman. '\
                              'If these features come from a Smart Proxy plugin, make sure Foreman has the plugin installed too.') % reply.to_sentence
        else
          errors.add :base, _('No features found on this proxy, please make sure you enable at least one feature')
        end
      end
    rescue => e
      errors.add(:base, _('Unable to communicate with the proxy: %s') % e)
      errors.add(:base, _('Please check the proxy is configured and running on the host.'))
    end
    throw :abort if features.empty?
  end
end
