module ProxyAPI
  class Features < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/features"
      super args
    end

    def features
      parse get
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to detect features"))
    end
  end
end
