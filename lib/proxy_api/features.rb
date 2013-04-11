module ProxyAPI
  class Features < Resource
    def initialize args
      @url  = args[:url] + "/features"
      super args
    end

    def features
      parse get
    end
  end
end
