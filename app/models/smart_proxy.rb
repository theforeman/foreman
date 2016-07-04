class SmartProxy < ActiveRecord::Base
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  include Parameterizable::ByIdName
  audited :allow_mass_assignment => true

  attr_accessible :name, :url, :location_ids, :organization_ids
  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups, :subnets, :domains, [:puppet_ca_hosts, :hosts], [:puppet_ca_hostgroups, :hostgroups], :realms)
  #TODO check if there is a way to look into the tftp_id too
  # maybe with a predefined sql
  has_and_belongs_to_many :features
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
  scoped_search :in => :features, :on => :name, :rename => :feature, :complete_value => :true

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
    return hostname unless Setting[:legacy_puppet_hostname]
    hostname.match(/^puppet\./) ? 'puppet' : hostname
  end

  def self.smart_proxy_ids_for(hosts)
    ids = []
    ids << hosts.joins(:primary_interface => :subnet).pluck('DISTINCT subnets.dhcp_id')
    ids << hosts.joins(:primary_interface => :subnet).pluck('DISTINCT subnets.tftp_id')
    ids << hosts.joins(:primary_interface => :subnet).pluck('DISTINCT subnets.dns_id')
    ids << hosts.joins(:primary_interface => :domain).pluck('DISTINCT domains.dns_id')
    ids << hosts.joins(:realm).pluck('DISTINCT realm_proxy_id')
    ids << hosts.pluck('DISTINCT puppet_proxy_id')
    ids << hosts.pluck('DISTINCT puppet_ca_proxy_id')
    ids << hosts.joins(:hostgroup).pluck('DISTINCT hostgroups.puppet_proxy_id')
    ids << hosts.joins(:hostgroup).pluck('DISTINCT hostgroups.puppet_ca_proxy_id')
    # returned both 7, "7". need to convert to integer or there are duplicates
    ids.flatten.compact.map { |i| i.to_i }.uniq
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
      conditions = "puppet_proxy_id = #{id} OR puppet_ca_proxy_id = #{id}"
    elsif has_feature?('Puppet')
      conditions[:puppet_proxy_id] = id
    elsif has_feature?('Puppet CA')
      conditions[:puppet_ca_proxy_id] = id
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
    self.url.chomp!('/') unless url.empty?
  end

  def associate_features
    begin
      proxy_response = ProxyAPI::Features.new(:url => url).features
    rescue => e
      errors.add(:base, _('Unable to communicate with the proxy: %s') % e)
      errors.add(:base, _('Please check the proxy is configured and running on the host.'))
    end

    return unless features_present?(proxy_response)
    self.features = find_features(proxy_response)
    unknown_features?(proxy_response, features)
  end

  def find_features(proxy_response)
    Feature.where(:name => proxy_response.map{ |f| Feature.name_map[f] } )
  end

  def unknown_features?(proxy_response, features)
    unknown_features = proxy_response - features.map(&:name).map(&:downcase)
    if unknown_features.present?
      errors.add(:base,
                 _("None of the features found on this proxy"\
                   "(%{unknown_features}) can be recognized by Foreman. "\
                   "Please enable at least one feature Foreman %{version}"\
                   "can recognize") %
                  { :unknown_features => unknown_features,
                    :version => SETTINGS[:version] } )
    end
  end

  def features_present?(proxy_response)
    if proxy_response.is_a?(Array) && proxy_response.any?
      true
    else
      errors.add(:base, _("No features found on this proxy, please make sure you"\
                          "enable at least one feature"))
      false
    end
  end
end
