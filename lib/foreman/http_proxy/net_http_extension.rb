Net::HTTP.class_eval do
  include Foreman::HTTPProxy
  alias_method :orig_request, :request

  def request(req, body = nil, &block)
    host = URI.parse(@address).host
    if proxy_http_request?(@proxy_address, host, @socket)
      log_proxied_request(http_proxy, host)
      @proxy_address = URI.parse(http_proxy)
      http_proxied_rescue do
        orig_request(req, body, &block)
      end
    else
      orig_request(req, body, &block)
    end
  end
end
