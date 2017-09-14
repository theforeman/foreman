module Foreman
  module HTTPProxy
    def http_proxy
      Setting[:http_proxy]
    end

    def http_proxy_except_list
      Setting[:http_proxy_except_list]
    end

    def proxy_http_request?(current_proxy, request_host, schema)
      !http_proxy.nil? && current_proxy.nil? && !request_host.nil? &&
      http_request?(schema) &&
      http_proxy_host?(request_host)
    end

    def http_proxied_rescue(&block)
      yield
    rescue => e
      raise e, _("Proxied request failed with: %s") % e, e.backtrace
    end

    private

    def http_request?(schema)
      ['http', 'https'].include?(schema)
    end

    def http_proxy_host?(request_host)
      !http_host_excepted?(request_host) &&
      !http_host_excepted_by_wildcard?(request_host)
    end

    def logger
      Foreman::Logging.logger('app')
    end

    def log_proxied_request(current_proxy, requested_host)
      logger.info "Proxying request to #{requested_host} via #{current_proxy}"
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

require_dependency File.expand_path('../http_proxy/excon_connection_extension', __FILE__)
require_dependency File.expand_path('../http_proxy/net_http_extension', __FILE__)
require_dependency File.expand_path('../http_proxy/rest_client_extension', __FILE__)
