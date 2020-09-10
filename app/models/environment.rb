class Environment < ApplicationRecord
  audited
  extend FriendlyId
  friendly_id :name, :reserved_words => []
  include Taxonomix
  include Authorizable
  include Parameterizable::ByName

  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)

  has_many :environment_classes, :dependent => :destroy
  has_many :puppetclasses, -> { distinct }, :through => :environment_classes
  has_many_hosts
  has_many :hostgroups

  validates :name, :uniqueness => true, :presence => true, :alphanumeric => true
  has_many :template_combinations, :dependent => :destroy
  has_many :provisioning_templates, :through => :template_combinations

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("environments.name")
    end
  }

  scoped_search :on => :name, :complete_value => :true

  class << self
    # TODO: this needs to be removed, as PuppetDOC generation no longer works
    # if the manifests are not on the foreman host
    # returns an hash of all puppet environments and their relative paths
    def puppetEnvs(proxy = nil)
      url = (proxy || SmartProxy.with_features("Puppet").first).try(:url)
      raise ::Foreman::Exception.new(N_("Can't find a valid Foreman Proxy with a Puppet feature")) if url.blank?
      proxy = ProxyAPI::Puppet.new :url => url
      HashWithIndifferentAccess[proxy.environments.map do |e|
        [e, HashWithIndifferentAccess[proxy.classes(e).map do |k|
          klass = k.keys.first
          [klass, k[klass]["params"]]
        end]]
      end]
    end
  end
end
