module Foreman
  module HttpProxy
    module NetHttpExtension
      def request(req, body = nil, &block)
        host = URI.parse(@address).host
        if proxy_http_request?(@proxy_address, host, @socket)
          log_proxied_request("NetHttp", http_proxy, host)
          @proxy_address = URI.parse(http_proxy)
          http_proxied_rescue do
            super(req, body, &block)
          end
        else
          super(req, body, &block)
        end
      end
    end
  end
end

Net::HTTP.class_eval do
  include Foreman::HTTPProxy
  prepend Foreman::HttpProxy::NetHttpExtension
end
