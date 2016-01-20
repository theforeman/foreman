module ProxyStatus
  class Base
    def initialize(proxy, opts = {})
      @proxy = proxy
      @cache_duration = opts[:cache_duration] || 3.minutes
      @cache = opts[:cache].nil? ? true : opts[:cache]
    end

    def revoke_cache!
      Rails.cache.delete(cache_key)
    end

    def cache_key
      "proxy_#{proxy.id}/#{self.class.humanized_name}"
    end

    def self.humanized_name
      'Base'
    end

    private

    attr_reader :proxy, :cache_duration, :cache

    def api
      @api = "ProxyAPI::#{self.class.humanized_name}".classify.constantize.new(:url => proxy.url)
    rescue NameError => e
      raise Foreman::WrappedException.new(e, N_('Unable to initialize ProxyAPI class %s'), "ProxyAPI::#{self.class.humanized_name}")
    end

    def fetch_proxy_data
      if cache
        Rails.cache.fetch(cache_key, :expires_in => cache_duration) do
          yield
        end
      else
        yield
      end
    rescue *ProxyStatus::CONNECTION_ERRORS => exception
      raise ::Foreman::WrappedException.new exception, N_("Unable to connect")
    end
  end
end
ProxyStatus.status_registry.add(ProxyStatus::Base)
