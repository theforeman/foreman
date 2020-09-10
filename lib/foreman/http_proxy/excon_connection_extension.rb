module Foreman
  module HttpProxy
    module ExconConnectionExtension
      def request(params, &block)
        if proxy_http_request?(@data[:proxy], @data[:host], @data[:scheme])
          log_proxied_request("Excon", http_proxy, @data[:host])
          @data[:proxy] = http_proxy
          setup_proxy
          http_proxied_rescue do
            super(params, &block)
          end
        else
          super(params, &block)
        end
      end
    end
  end
end

Excon::Connection.class_eval do
  include Foreman::HTTPProxy
  prepend Foreman::HttpProxy::ExconConnectionExtension
end
