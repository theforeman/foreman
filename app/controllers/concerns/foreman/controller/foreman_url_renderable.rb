module Foreman::Controller::ForemanUrlRenderable
  #returns the URL for Foreman based on the required action
  def foreman_url(action = 'provision')
    # Only proxy templates if both the proxy and the host support it

    host = self.is_a?(Host::Base) ? self : @host

    proxy = host.try(:subnet).try(:tftp)

    if @template_url && @host.try(:token).present?
      foreman_url_from_uri(action, @template_url, host.token)
    elsif proxy.present? && proxy.try(:features).map(&:name).include?('Templates') && host.try(:token).present?
      foreman_url_from_templates_smart_proxy_plugin(action, proxy, host.token)
    else
      foreman_url_from_config_or_request(action, host.token)
    end
  end

  private

  def foreman_url_from_config_or_request(action, token)
    config   = URI.parse(Setting[:unattended_url])
    protocol = config.scheme || 'http'
    port     = config.port || request.port
    hostname     = config.host || request.host

    url_for_foreman_url(action, protocol, hostname, port, token)
  end

  def foreman_url_from_templates_smart_proxy_plugin(action, proxy, token)
    url = ProxyAPI::Template.new(:url => proxy.url).template_url
    if url.nil?
      logger.warn("unable to obtain template url set by proxy #{proxy.url}. falling back on proxy url.")
      url = proxy.url
    end
    foreman_url_from_uri(action, url, token)
  end

  def foreman_url_from_uri(action, url, token)
    uri      = URI.parse(url)
    host     = uri.host
    port     = uri.port
    protocol = uri.scheme
    url_for_foreman_url(action, protocol, host, port, token)
  end

  def url_for_foreman_url(action, protocol, host, port, token)
    url_for :only_path => false, :controller => "/unattended", :action => action,
      :protocol  => protocol, :host => host, :port => port,
      :token     => (token.value unless token.nil?)
  end
end
