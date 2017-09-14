Excon::Connection.class_eval do
  include Foreman::HTTPProxy
  alias_method :orig_request, :request

  def request(params, &block)
    if proxy_http_request?(@data[:proxy], @data[:host], @data[:scheme])
      log_proxied_request(http_proxy, @data[:host])
      @data[:proxy] = http_proxy
      setup_proxy
      http_proxied_rescue do
        orig_request(params, &block)
      end
    else
      orig_request(params, &block)
    end
  end
end
