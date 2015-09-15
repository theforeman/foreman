class PuppetEnvironment < Environment
  has_many :environment_classes, :dependent => :destroy, :foreign_key => 'environment_id'
  has_many :puppetclasses, :through => :environment_classes, :uniq => true

  class << self
    #TODO: this needs to be removed, as PuppetDOC generation no longer works
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
