module ProxyAPI
  class Template < ProxyAPI::Resource
    def initialize args
      @url     = args[:url] + "/unattended"
      super args
    end

    # returns the Template URL for this proxy
    def template_url
      if (response = parse(get("templateServer"))) and response["templateServer"].present?
        return response["templateServer"]
      end
    rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
      EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
      Net::ProtocolError, RestClient::ResourceNotFound => e
      logger.warn("failed to obtain template server from smart-proxy #{@url}")
      nil
    end

  end
end
