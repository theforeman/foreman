class Environment < ActiveRecord::Base
  has_many :environment_classes, :dependent => :destroy
  has_many :puppetclasses, :through => :environment_classes, :uniq => true
  has_many :hosts
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name, :with => /^[\w\d]+$/, :message => "is alphanumeric and cannot contain spaces"
  has_many :config_templates, :through => :template_combinations, :dependent => :destroy
  has_many :template_combinations

  before_destroy EnsureNotUsedBy.new(:hosts)
  default_scope :order => 'environments.name'

  scoped_search :on => :name, :complete_value => :true

  def to_param
    name
  end

  class << self

    #TODO: this needs to be removed, as PuppetDOC generation no longer works
    # if the manifests are not on the foreman host
    # returns an hash of all puppet environments and their relative paths
    def puppetEnvs proxy = nil

      url = (proxy || SmartProxy.puppet_proxies.first).try(:url)
      raise "Can't find a valid Foreman Proxy with a Puppet feature" if url.blank?
      proxy = ProxyAPI::Puppet.new :url => url
      HashWithIndifferentAccess[proxy.environments.map { |e|
        [e, HashWithIndifferentAccess[proxy.classes(e).map {|k|
          klass = k.keys.first
          [klass, k[klass]["params"]]
        }]]
      }]
    end

  end

  def as_json(options={ })
    options ||= { }
    super({ :only => [:name, :id] }.merge(options))
  end

end
