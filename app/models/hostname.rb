class Hostname < ApplicationRecord
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  audited

  has_and_belongs_to_many :smart_proxies

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups, [:puppet_ca_hosts, :hosts], [:puppet_ca_hostgroups, :hostgroups])

  has_many :features, :through => :smart_proxies
  has_many_hosts                                              :foreign_key => 'puppet_proxy_hostname_id'
  has_many :hostgroups,                                       :foreign_key => 'puppet_proxy_hostname_id'
  has_many :puppet_ca_hosts, :class_name => 'Host::Managed',  :foreign_key => 'puppet_ca_proxy_hostname_id'
  has_many :puppet_ca_hostgroups, :class_name => 'Hostgroup', :foreign_key => 'puppet_ca_proxy_hostname_id'

  validates :hostname, :length => {:maximum => 255}, :presence => true, :uniqueness => true
  validates :name, :uniqueness => true, :presence => true

  before_save :sanitize_hostname

  attr_name :name

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :hostname, :complete_value => :true
  scoped_search :relation => :smart_proxies, :on => :name, :rename => :smart_proxy, :only_explicit => true

  scope :with_features, ->(*feature_names) { where(:features => { :name => feature_names }).joins(:features) if feature_names.any? }

  def to_label
    return name
  end

  def has_feature?(feature)
    self.smart_proxies.first.try(:has_feature?, feature) || false
  end

  def self.hostname_ids_for(hosts)
    ids = []
    ids << hosts.pluck('DISTINCT puppet_proxy_hostname_id')
    ids << hosts.pluck('DISTINCT puppet_ca_proxy_hostname_id')
    ids << hosts.joins(:hostgroup).pluck('DISTINCT hostgroups.puppet_proxy_hostname_id')
    ids << hosts.joins(:hostgroup).pluck('DISTINCT hostgroups.puppet_ca_proxy_hostname_id')
    # returned both 7, "7". need to convert to integer or there are duplicates
    ids.flatten.compact.map { |i| i.to_i }.uniq
  end

  def taxonomy_foreign_conditions
    conditions = {}
    if has_feature?('Puppet') && has_feature?('Puppet CA')
      conditions = "puppet_proxy_hostname_id = #{id} OR puppet_ca_proxy_hostname_id = #{id}"
    elsif has_feature?('Puppet')
      conditions[:puppet_proxy_hostname_id] = id
    elsif has_feature?('Puppet CA')
      conditions[:puppet_ca_proxy_hostname_id] = id
    end
    conditions
  end

  private

  def sanitize_hostname
    self.hostname = hostname.downcase unless hostname.empty?
  end
end
