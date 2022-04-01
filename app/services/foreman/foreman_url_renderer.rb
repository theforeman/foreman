module Foreman
  module ForemanUrlRenderer
    # foreman_url macro uses url_for, therefore we need url helpers and fake default_url_options
    # if it's not defined in class the we mix into
    include Rails.application.routes.url_helpers
    extend ApipieDSL::Module

    apipie :class, 'Foreman URL macro class' do
      name 'ForemanUrlRenderer'
      sections only: %w[all reports provisioning jobs partition_tables]
    end

    def default_url_options
      {}
    end

    apipie :method, 'Returns Foreman unattended URL' do
      desc 'Returns URL to Foreman or Smart Proxy depending on host.subnet.template proxy configuration.'
      required :action, String, desc: 'template kind (provision, script, ...)'
      optional :params, Hash, desc: 'URL parameters, which will be URL-escaped'
      optional :unescaped_params, Hash, desc: 'URL parameters, which will be added raw - not URL-escaped'
      returns String, desc: "Rendered URL"
    end
    def foreman_url(action, params = {}, unescaped_params = {})
      options = foreman_url_options
      config = options[:config]
      host = options[:host]
      url_options = options[:url_options]

      # Set token
      params[:token] = host.token.value if host.try(:build) && host.try(:token)

      # Parameters which must not be URL-encoded (e.g. iPXE synax ${xxx})
      raw_string = ''
      if unescaped_params.any?
        raw_string += params.any? ? '&' : '?'
        raw_string += unescaped_params.map { |k, v| "#{k}=#{v}" }.join('&')
      end

      url_options[:action] = action
      url_options[:path] = config.path
      render_foreman_url(host, url_options, params) + raw_string
    end

    apipie :method, 'Returns address part of Foreman unattended URL' do
      desc 'Returns the "Foreman or Smart Proxy FQDN including port" part of the unattended URL, depending on host.subnet.template proxy configuration.'
      returns String, desc: "Rendered request address"
    end
    def foreman_request_addr
      url_options = foreman_url_options[:url_options]

      result = url_options[:host]
      result += ":#{url_options[:port]}" unless url_options[:port].to_s.empty? || url_options[:port] == 80
      result
    end

    private

    def foreman_url_options
      # Get basic stuff
      config = URI.parse(Setting[:unattended_url])
      url_options = foreman_url_options_from_settings_or_request(config)

      host = @host
      host = self if @host.nil? && self.class < Host::Base
      template_proxy = host.try(:provision_interface).try(:subnet).try(:template_proxy)

      # Use template_url from the request if set, but otherwise look for a Template
      # feature proxy, as PXE templates are written without an incoming request.
      url = @template_url
      url ||= foreman_url_from_templates_proxy(template_proxy) if template_proxy.present?

      url_options = foreman_url_options_from_url(url) if url.present?

      { :config => config, :host => host, :url_options => url_options }
    end

    def foreman_url_options_from_settings_or_request(config)
      {
        :protocol => config.scheme || 'http',
        :host     => config.host || request.host,
        :port     => config.port || request.port,
      }
    end

    def foreman_url_options_from_url(url)
      uri = URI.parse(url)
      {
        :host     => uri.host,
        :port     => uri.port,
        :protocol => uri.scheme,
      }
    end

    def render_foreman_url(host, options, params)
      url_for :only_path => false, :controller => "/unattended", :action => 'host_template',
        :protocol => options[:protocol], :host => options[:host],
        :port => options[:port], :script_name => options[:path],
        :kind => options[:action], **params
    end

    def foreman_url_from_templates_proxy(proxy)
      url = proxy.template_url
      if url.nil?
        template_logger.warn("unable to obtain template url set by proxy #{proxy.url}. falling back on proxy url.")
        url = proxy.url
      end
      url
    end

    def template_logger
      @template_logger ||= Foreman::Logging.logger('templates')
    end
  end
end
