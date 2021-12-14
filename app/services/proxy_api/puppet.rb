module ProxyAPI
  class Puppet < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/puppet"
      super args
    end

    def environments
      parse(get("environments"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to get environments from Puppet"))
    end

    def environment(env)
      parse(get("environments/#{env}"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to get environment from Puppet"))
    end

    def classes(env)
      return if env.blank?
      pcs = parse(get("environments/#{env}/classes"))
      Hash[pcs.map { |k| [k.keys.first, Foreman::ImporterPuppetclass.new(k.values.first)] }]
    rescue RestClient::ResourceNotFound
      {}
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to get classes from Puppet for %s"), env)
    end

    def class_count(env)
      return if env.blank?
      pcs = parse(get("environments/#{env}/classes"))
      pcs.length
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to get classes from Puppet for %s"), env)
    end
  end
end
