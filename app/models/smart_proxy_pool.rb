class SmartProxyPool < ApplicationRecord
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  audited

  has_and_belongs_to_many :smart_proxies, :join_table => :pools_smart_proxies

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups, [:puppet_ca_hosts, :hosts], [:puppet_ca_hostgroups, :hostgroups])

  has_many :features, :through => :smart_proxies
  has_many_hosts                                              :foreign_key => 'puppet_proxy_pool_id'
  has_many :hostgroups,                                       :foreign_key => 'puppet_proxy_pool_id'
  has_many :puppet_ca_hosts, :class_name => 'Host::Managed',  :foreign_key => 'puppet_ca_proxy_pool_id'
  has_many :puppet_ca_hostgroups, :class_name => 'Hostgroup', :foreign_key => 'puppet_ca_proxy_pool_id'

  validates :hostname, :length => {:maximum => 255}, :presence => true, :uniqueness => true
  validates :name, :uniqueness => true, :presence => true
  validate :same_features, :if => Proc.new { |pool| pool.smart_proxies.any? }
  validate :vaild_certs, :if => Proc.new { |pool| pool.smart_proxies.any? }

  before_save :sanitize_hostname

  attr_name :name

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :hostname, :complete_value => :true
  scoped_search :relation => :smart_proxies, :on => :name, :rename => :smart_proxy, :only_explicit => true

  scope :with_features, ->(*feature_names) { where(:features => { :name => feature_names }).joins(:features) if feature_names.any? }

  def to_label
    name
  end

  def has_feature?(feature)
    self.smart_proxies.first.try(:has_feature?, feature) || false
  end

  def self.smart_proxy_pool_ids_for(hosts)
    ids = []
    ids << hosts.pluck('DISTINCT puppet_proxy_pool_id')
    ids << hosts.pluck('DISTINCT puppet_ca_proxy_pool_id')
    ids << hosts.joins(:hostgroup).pluck('DISTINCT hostgroups.puppet_proxy_pool_id')
    ids << hosts.joins(:hostgroup).pluck('DISTINCT hostgroups.puppet_ca_proxy_pool_id')
    # returned both 7, "7". need to convert to integer or there are duplicates
    ids.flatten.compact.map { |i| i.to_i }.uniq
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

  private

  def same_features
    features = smart_proxies.first.try(:features)
    smart_proxies.drop(1).each do |proxy|
      unless features.sort == proxy.features.sort
        errors.add(:smart_proxies, _("Smart Proxy \"#{smart_proxies.first.name}\" and \"#{proxy.name}\" have different features"))
      end
    end
  end

  def vaild_certs(override_port = nil)
    # Allows plugins to override the port
    smart_proxies.each do |proxy|
      if proxy.url =~ /^https/i
        port = override_port || proxy.port
        cert_raw = GetRawCertificate.new(proxy.hostname, port).cert
        cert = CertificateExtract.new(cert_raw)
        possible_names = cert.subject_alternative_names + [cert.subject]
        unless possible_names.include?(hostname)
          errors.add(:hostname, _("Certificate on #{proxy.hostname}:#{port} does not verify #{hostname}"))
        end
      end
    end
  end

  def sanitize_hostname
    self.hostname = hostname.downcase unless hostname.empty?
  end
end
