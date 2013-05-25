module ProxyAPI
  class Puppetca < ProxyAPI::Resource
    def initialize args
      @url  = args[:url] + "/puppet/ca"
      super args
    end

    def autosign
      parse(get "autosign")
    end

    def set_autosign certname
      parse(post("", "autosign/#{certname}"))
    end

    def del_autosign certname
      parse(delete("autosign/#{certname}"))
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      true
    end

    def sign_certificate certname
      parse(post("", certname))
    end

    def del_certificate certname
      parse(delete("#{certname}"))
    rescue RestClient::ResourceNotFound
      # entry doesn't exists anyway
      true
    end

    def all
      parse(get)
    end
  end
end
