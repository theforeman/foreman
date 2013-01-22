require 'resolv'
require 'uri'

module Foreman::Controller::SmartProxyAuth
  extend ActiveSupport::Concern

  module ClassMethods
    def add_puppetmaster_filters(actions)
      skip_before_filter :require_login, :only => actions
      skip_before_filter :require_ssl, :only => actions
      skip_before_filter :authorize, :only => actions
      skip_before_filter :verify_authenticity_token, :only => actions
      skip_before_filter :set_taxonomy, :only => actions
      skip_before_filter :session_expiry, :update_activity_time, :only => actions
      before_filter :require_puppetmaster_or_login, :only => actions
    end
  end

  module InstanceMethods
    # Permits registered puppetmasters or a user with permission
    def require_puppetmaster_or_login
      if !Setting[:restrict_registered_puppetmasters] or auth_smart_proxy(SmartProxy.puppet_proxies, Setting[:require_ssl_puppetmasters])
        set_admin_user
        return true
      end

      require_login
      unless User.current
        render_403 unless performed?
        return false
      end
      authorize
    end

    # Filter requests to only permit from hosts with a registered smart proxy
    # Uses rDNS of the request to match proxy hostnames
    def auth_smart_proxy(proxies = SmartProxy.all, require_cert = true)
      request_hosts = nil
      if request.ssl?
        if cn = request.env[Setting[:ssl_client_cn_env]]
          if request.env[Setting[:ssl_client_verify_env]] == 'SUCCESS'
            request_hosts = [cn]
          else
            logger.warn "SSL cert for #{cn} has not been verified - request from #{request.ip}"
          end
        elsif require_cert
          logger.warn "No SSL cert with CN supplied - request from #{request.ip}"
        else
          request_hosts = Resolv.new.getnames(request.ip)
        end
      elsif SETTINGS[:require_ssl]
        logger.warn "SSL is required - request from #{request.ip}"
      else
        request_hosts = Resolv.new.getnames(request.ip)
      end
      return false unless request_hosts

      logger.debug("Verifying request from #{request_hosts} against #{proxies.map { |p| URI.parse(p.url).host }.inspect}")
      unless proxies.detect { |p| request_hosts.include? URI.parse(p.url).host }
        logger.warn "No smart proxy server found on #{request_hosts.inspect}"
        return false
      end
      true
    end
  end
end
