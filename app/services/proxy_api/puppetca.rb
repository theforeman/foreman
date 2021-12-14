module ProxyAPI
  class Puppetca < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/puppet/ca"
      super args
    end

    def autosign
      parse(get("autosign"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to get PuppetCA autosign"))
    end

    def set_autosign(certname)
      parse(post("", "autosign/#{certname}"))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to set PuppetCA autosign for %s"), certname)
    end

    def del_autosign(certname)
      parse(delete("autosign/#{certname}"))
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      true
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to delete PuppetCA autosign for %s"), certname)
    end

    def sign_certificate(certname)
      parse(post("", certname))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to sign PuppetCA certificate for %s"), certname)
    end

    def del_certificate(certname)
      parse(delete(certname.to_s))
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      true
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to delete PuppetCA certificate for %s"), certname)
    end

    def all
      parse(get)
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to get PuppetCA certificates"))
    end
  end
end
