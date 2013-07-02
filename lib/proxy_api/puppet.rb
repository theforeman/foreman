module ProxyAPI
  class Puppet < ProxyAPI::Resource
    def initialize args
      @url  = args[:url] + "/puppet"
      super args
    end

    def environments
      parse(get "environments")
    end

    def environment env
      parse(get "environments/#{env}")
    end

    def classes env
      return if env.blank?
      pcs = parse(get "environments/#{env}/classes")
      Hash[pcs.map { |k| [k.keys.first, Foreman::ImporterPuppetclass.new(k.values.first)] }]
    rescue RestClient::ResourceNotFound
      []
    end

    def run hosts
      parse(post({:nodes => hosts}, "run"))
    end
  end
end
