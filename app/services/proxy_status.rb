class ProxyStatus
  CONNECTION_ERRORS = [Errno::EINVAL, Errno::ECONNRESET, EOFError, Timeout::Error, Errno::ENOENT,
                       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError]

  def initialize(proxy, opts = {})
    @proxy = proxy
    @cache_duration = opts[:cache_duration] || 3.minutes
    @api ||= ProxyAPI::Version.new(:url => proxy.url)
  end

  def api_versions
    Rails.cache.fetch(versions_cache_key, :expires_in => cache_duration) do
      fetch_proxy_data do
        api.proxy_versions
      end
    end
  end

  # TODO: extract to another status implementation
  def tftp_server
    raise ::Foreman::Exception.new(N_('No TFTP feature for %s'), proxy.to_label) unless proxy.has_feature?('TFTP')
    Rails.cache.fetch("proxy_#{proxy.id}/tftp_server", :expires_in => cache_duration) do
      fetch_proxy_data do
        ProxyAPI::TFTP.new(:url => proxy.url).bootServer
      end
    end
  end

  def revoke_cache!
    # As memcached does not support delete_matched, we need to delete each
    Rails.cache.delete(versions_cache_key)
    Rails.cache.delete("proxy_#{proxy.id}/tftp_server")
  end

  def versions_cache_key
    "proxy_#{proxy.id}/versions"
  end

  private

  attr_reader :proxy, :cache_duration, :api
  alias_method :version, :api_versions

  def fetch_proxy_data
    begin
      yield
    rescue *CONNECTION_ERRORS => exception
      raise ::Foreman::WrappedException.new exception, N_("Unable to connect to smart proxy")
    end
  end
end
