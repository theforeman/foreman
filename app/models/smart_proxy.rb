class SmartProxy < ActiveRecord::Base
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  include Parameterizable::ByIdName
  audited :allow_mass_assignment => true

  attr_accessible :name, :url, :location_ids, :organization_ids
  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups, :subnets, :domains, :puppet_ca_hosts, :puppet_ca_hostgroups, :realms)
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
  URL_HOSTNAME_MATCH = %r{^(?:http|https):\/\/([^:\/]+)}
  validates :name, :uniqueness => true, :presence => true
  validates :url, :presence => true, :format => { :with => URL_HOSTNAME_MATCH, :message => N_('is invalid - only  http://, https:// are allowed') },
            :uniqueness     => { :message => N_('Only one declaration of a proxy is allowed') }

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

  Feature.name_map.each do |f, v|
    scope "#{f}_proxies".to_sym,
      lambda {
        ActiveSupport::Deprecation.warn "Scope 'SmartProxy.#{f}_proxies' has been deprecated. Please use 'SmartProxy.with_features' instead", caller
        where(:features => { :name => v }).joins(:features)
      }
  end
  scope :with_features, lambda {|*feature_names| where(:features => { :name => feature_names }).joins(:features) if feature_names.any? }

  def hostname
    # This will always match as it is validated
    url.match(URL_HOSTNAME_MATCH)[1]
  end

  def to_s
    if Setting[:legacy_puppet_hostname]
      hostname =~ /^puppet\./ ? 'puppet' : hostname
    else
      hostname
    end
  end

  def self.smart_proxy_ids_for(hosts)
    ids = []
    ids << hosts.joins(:subnet).pluck('DISTINCT subnets.dhcp_id')
    ids << hosts.joins(:subnet).pluck('DISTINCT subnets.tftp_id')
    ids << hosts.joins(:subnet).pluck('DISTINCT subnets.dns_id')
    ids << hosts.joins(:domain).pluck('DISTINCT domains.dns_id')
    ids << hosts.joins(:realm).pluck('DISTINCT realm_proxy_id')
    ids << hosts.pluck('DISTINCT puppet_proxy_id')
    ids << hosts.pluck('DISTINCT puppet_ca_proxy_id')
    ids << hosts.joins(:hostgroup).pluck('DISTINCT hostgroups.puppet_proxy_id')
    ids << hosts.joins(:hostgroup).pluck('DISTINCT hostgroups.puppet_ca_proxy_id')
    # returned both 7, "7". need to convert to integer or there are duplicates
    ids.flatten.compact.map { |i| i.to_i }.uniq
  end

  def refresh
    associate_features
    errors
  end

  def taxonomy_foreign_conditions
    feature_names = self.features.pluck(:name)
    conditions                      = {}
    if feature_names.include?('Puppet') && feature_names.include?('Puppet CA')
      conditions = "puppet_proxy_id = #{id} OR puppet_ca_proxy_id = #{id}"
    elsif feature_names.include?('Puppet')
      conditions[:puppet_proxy_id] = id
    elsif feature_names.include?('Puppet CA')
      conditions[:puppet_ca_proxy_id] = id
    end
    conditions
  end

  private

  def sanitize_url
    self.url.chomp!('/') unless url.empty?
  end

  def associate_features
    return true if Rails.env == 'test'

    begin
      reply = ProxyAPI::Features.new(:url => url).features
      if reply.is_a?(Array) and reply.any?
        self.features = Feature.where(:name => reply.map{|f| Feature.name_map[f]})
      else
        self.features.clear
        errors.add :base, _('No features found on this proxy, please make sure you enable at least one feature')
      end
    rescue => e
      errors.add(:base, _('Unable to communicate with the proxy: %s') % e)
      errors.add(:base, _('Please check the proxy is configured and running on the host.'))
    end
    features.any?
  end
end
