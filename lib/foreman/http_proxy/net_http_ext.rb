module Foreman
  module HttpProxy
    class NetHttpExt < Net::HTTP
      include Foreman::HTTPProxy

      def proxy?
        !!proxy_uri
      end

      def proxy_uri
        return @foreman_proxy_uri if defined?(@foreman_proxy_uri)
        if proxy_http_request?(@proxy_address, address, use_ssl? ? 'https' : 'http')
          log_proxied_request("NetHttp", http_proxy, address)
          @foreman_proxy_uri = URI.parse http_proxy
        end
      end
    end
  end
end
