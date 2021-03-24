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

      def net_http_object(hostname, port)
        p_uri = proxy_uri

        if p_uri.nil?
          # no proxy set
          Net::HTTP.new(hostname, port)
        elsif !p_uri
          # proxy explicitly set to none
          Net::HTTP.new(hostname, port, nil, nil, nil, nil)
        else
          proxy_pass = CGI.unescape(p_uri.password) if p_uri.password
          proxy_user = CGI.unescape(p_uri.user) if p_uri.user
          Net::HTTP.new(hostname, port,
            p_uri.hostname, p_uri.port, proxy_user, proxy_pass)
        end
      end
    end
  end
end

RestClient::Request.class_eval do
  include Foreman::HTTPProxy
  prepend Foreman::HttpProxy::RestClientExtension
end
