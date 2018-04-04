require 'resolv'
require 'uri'

module Foreman::Controller::SmartProxyAuth
  extend ActiveSupport::Concern

  module ClassMethods
    def add_smart_proxy_filters(actions, options = {})
      skip_before_action :require_login, :only => actions, :raise => false
      skip_before_action :authorize, :only => actions
      skip_before_action :verify_authenticity_token, :only => actions
      skip_before_action :set_taxonomy, :only => actions, :raise => false
      skip_before_action :session_expiry, :update_activity_time, :only => actions
      before_action(:only => actions) { require_smart_proxy_or_login(options[:features]) }
      attr_reader :detected_proxy

      cattr_accessor :smart_proxy_filter_actions
      self.smart_proxy_filter_actions ||= []
      self.smart_proxy_filter_actions.push(*actions)

      prepend SmartProxyRequireSsl
    end
  end

  module SmartProxyRequireSsl
    def require_ssl?
      if [self.smart_proxy_filter_actions].flatten.map(&:to_s).include?(self.action_name)
        false
      else
        super
      end
    end
  end

  private

  # Permits registered Smart Proxies or a user with permission
  def require_smart_proxy_or_login(features = nil)
    features = features.call if features.respond_to?(:call)
    allowed_smart_proxies = if features.blank?
                              SmartProxy.unscoped.all
                            else
                              SmartProxy.unscoped.with_features(*features)
                            end

    if !Setting[:restrict_registered_smart_proxies] || auth_smart_proxy(allowed_smart_proxies, Setting[:require_ssl_smart_proxies])
      set_admin_user
      return true
    end

    require_login
    unless User.current
      render_error 'access_denied', :status => :forbidden unless performed? && api_request?
      return false
    end
    authorize
  end

  # Filter requests to only permit from hosts with a registered smart proxy
  # Uses rDNS of the request to match proxy hostnames
  def auth_smart_proxy(proxies = SmartProxy.unscoped.all, require_cert = true)
    request_hosts = nil
    if request.ssl?
      # If we have the client certficate in the request environment we can extract the dn and sans from there
      # if not we use the dn in the request environment
      # SAN validation requires "SSLOptions +ExportCertData" in Apache httpd
      if request.env.has_key?(Setting[:ssl_client_cert_env]) && request.env[Setting[:ssl_client_cert_env]].present?
        logger.debug "Examining client certificate to extract dn and sans"
        cert_raw = request.env[Setting[:ssl_client_cert_env]]
        certificate = CertificateExtract.new(cert_raw)
        logger.debug "Client sent certificate with subject '#{certificate.subject}' and subject alt names '#{certificate.subject_alternative_names.inspect}'"
      else
        dn = request.env[Setting[:ssl_client_dn_env]]
      end

      if (dn && dn =~ /CN=([^\s\/,]+)/i) || certificate
        verify = request.env[Setting[:ssl_client_verify_env]]
        if verify == 'SUCCESS'
          # If the client sent certificate contains a subject or sans, use them for request_hosts, else fall back to the dn set in the request environment
          request_hosts = []
          if certificate
            if certificate.subject_alternative_names.present?
              request_hosts += certificate.subject_alternative_names
            elsif certificate.subject
              request_hosts << certificate.subject
            end
          else
            request_hosts << Regexp.last_match(1) if Regexp.last_match(1)
          end
        else
          logger.warn "SSL cert has not been verified (#{verify}) - request from #{request.ip}, #{dn}"
        end
      elsif require_cert
        logger.warn "No SSL cert with CN supplied - request from #{request.ip}, #{dn}"
      else
        request_hosts = Resolv.new.getnames(request.ip)
      end
    elsif SETTINGS[:require_ssl]
      logger.warn "SSL is required - request from #{request.ip}"
    else
      request_hosts = Resolv.new.getnames(request.ip)
      request_hosts = [request.ip] if request_hosts == []
    end
    return false unless request_hosts

    hosts = Hash[proxies.map { |p| [URI.parse(p.url).host, p] }]
    allowed_hosts = hosts.keys.push(*Setting[:trusted_hosts])
    logger.debug { "Verifying request from #{request_hosts.inspect} against #{allowed_hosts.inspect}" }

    if (host = detect_matching_host(allowed_hosts, request_hosts))
      @detected_proxy = hosts[host] if host
      true
    else
      logger.warn "No smart proxy server found on #{request_hosts.inspect} and is not in trusted_hosts"
      false
    end
  end

  def detect_matching_host(allowed_hosts, request_hosts)
    allowed_hosts.product(request_hosts).each do |allowed, request|
      if request.starts_with?('*')
        rex = /\A#{Regexp.escape(request).sub('\\*', '.*')}\Z/
        return allowed if allowed =~ rex
      else
        return allowed if allowed == request
      end
    end

    nil
  end
end
