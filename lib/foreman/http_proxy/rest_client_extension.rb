module Foreman
  module HttpProxy
    module RestClientExtension
      def proxy_uri
        if proxy_http_request?(@proxy, @uri.hostname, @uri.scheme)
          log_proxied_request("RestClient", http_proxy, @uri.hostname)
          return URI.parse(http_proxy)
        end
        super
      end
    end
  end
end

RestClient::Request.class_eval do
  include Foreman::HTTPProxy
  prepend Foreman::HttpProxy::RestClientExtension
end
