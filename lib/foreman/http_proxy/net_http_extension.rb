module Foreman
  module HttpProxy
    module NetHttpExtension
      def request(req, body = nil, &block)
        if proxy_http_request?(@proxy_address, address, req&.uri&.scheme)
          log_proxied_request("NetHttp", http_proxy, address)
          @proxy_from_env = false
          @proxy_address = http_proxy
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
