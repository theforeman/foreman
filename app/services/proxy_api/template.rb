module ProxyAPI
  class Template < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + "/unattended"
      super args
    end

    # returns the Template URL for this proxy
    def template_url
      if (response = parse(get("templateServer"))) && response["templateServer"].present?
        response["templateServer"]
      end
    rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
           EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
           Net::ProtocolError, RestClient::ResourceNotFound => e
      Foreman::Logging.exception("Failed to obtain template server from smart-proxy #{@url}", e)
      nil
    end
  end
end
