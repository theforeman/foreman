module ProxyAPI::V2
  class Features < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/v2/features"
      super args
    end

    def features
      parse get
    rescue RestClient::ResourceNotFound
      raise NotImplementedError
    rescue => e
      raise ProxyAPI::ProxyException.new(url, e, N_("Unable to detect features"))
    end
  end
end
