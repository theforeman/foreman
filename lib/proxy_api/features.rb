module ProxyAPI
  class Features < ProxyAPI::Resource
    def initialize args
      @url  = args[:url] + "/features"
      super args
    end

    def features
      parse get
    end
  end
end
