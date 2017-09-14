RestClient::Request.class_eval do
  include Foreman::HTTPProxy
  alias_method :orig_proxy_uri, :proxy_uri

  def proxy_uri
    if proxy_http_request?(@proxy, @uri.hostname, @uri.scheme)
      log_proxied_request(http_proxy, @uri.hostname)
      return URI.parse(http_proxy)
    end
    orig_proxy_uri
  end
end
