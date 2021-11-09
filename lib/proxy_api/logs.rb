module ProxyAPI
  class Logs < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/logs"
      super args
    end

    def all(from = 0)
      parse(get("", query: { from_timestamp: from }))
    rescue => e
      raise ProxyException.new(url, e, N_("Unable to fetch logs"))
    end
  end
end
