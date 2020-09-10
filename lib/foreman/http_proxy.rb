module Foreman
  module HTTPProxy
    def http_proxy
      ActiveRecord::Base.connection_pool.with_connection do
        Setting[:http_proxy].presence
      end
    end

    def http_proxy_except_list
      ActiveRecord::Base.connection_pool.with_connection do
        Setting[:http_proxy_except_list]
      end
    end

    # Answers if this request should be proxied
    def proxy_http_request?(current_proxy, request_host, schema)
      !http_proxy.nil? &&
      current_proxy.nil? &&
      !request_host.nil? &&
      http_request?(schema) &&
      http_proxy_host?(request_host) &&
      !local_request?(request_host)
    end

    def http_proxied_rescue(&block)
      yield
    rescue => e
      raise e, _("Proxied request failed with: %s\n%s") % [e, e&.backtrace&.join("\n")]
    end

    private

    def local_request?(request_host)
      request_host.starts_with?('127.') ||
      request_host == 'localhost' ||
      request_host == '::1' ||
      request_host == SETTINGS[:fqdn]
    end

    def http_request?(schema)
      ['http', 'https'].include?(schema)
    end

    def http_proxy_host?(request_host)
      !http_host_excepted?(request_host) &&
      !http_host_excepted_by_wildcard?(request_host)
    end

    def foreman_logger
      Foreman::Logging.logger('app')
    end

    def log_proxied_request(lib, current_proxy, requested_host)
      foreman_logger.info "(#{lib}) Proxying request to #{requested_host} via #{current_proxy}"
    end

    def http_host_excepted_by_wildcard?(host)
      return false if http_proxy_except_list.empty?
      host =~ Setting.convert_array_to_regexp(http_proxy_except_list)
    end

    def http_host_excepted?(host)
      http_proxy_except_list.include? host
    end
  end
end

require_dependency File.expand_path('http_proxy/excon_connection_extension', __dir__)
require_dependency File.expand_path('http_proxy/net_http_extension', __dir__)
require_dependency File.expand_path('http_proxy/rest_client_extension', __dir__)
