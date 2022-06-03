module Foreman
  module HttpProxy
    module RestClientExtension
      def proxy_uri
        return if @args[:force_direct]
        if proxy_http_request?(@proxy, @uri.hostname, @uri.scheme)
          log_proxied_request("RestClient", http_proxy, @uri.hostname)
          return URI.parse(http_proxy)
        end
        super
      end

      def net_http_object(hostname, port)
        p_uri = proxy_uri

        # no proxy set or proxy explicitly set to none
        return super unless p_uri

        proxy_pass = CGI.unescape(p_uri.password) if p_uri.password
        proxy_user = CGI.unescape(p_uri.user) if p_uri.user
        Net::HTTP.new(hostname, port,
          p_uri.hostname, p_uri.port, proxy_user, proxy_pass)
      end
    end
  end
end

RestClient::Request.class_eval do
  include Foreman::HTTPProxy
  prepend Foreman::HttpProxy::RestClientExtension
end
