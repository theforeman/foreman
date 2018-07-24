class Setting::General < Setting
  include UrlValidator

  def self.default_settings
    protocol = SETTINGS[:require_ssl] ? 'https' : 'http'
    domain = SETTINGS[:domain]
    administrator = "root@#{domain}"
    foreman_url = "#{protocol}://#{SETTINGS[:fqdn]}"

    [
      self.set('administrator', N_("The default administrator email address"), administrator, N_('Administrator email address')),
      self.set('foreman_url', N_("URL where your Foreman instance is reachable (see also Provisioning > unattended_url)"), foreman_url, N_('Foreman URL')),
      self.set('entries_per_page', N_("Number of records shown per page in Foreman"), 20, N_('Entries per page')),
      self.set('fix_db_cache', N_('Fix DB cache on next Foreman restart'), false, N_('Fix DB cache')),
      self.set('max_trend', N_("Max days for Trends graphs"), 30, N_('Max trends')),
      self.set('db_pending_migration', N_("Should the `foreman-rake db:migrate` be executed on the next run of the installer modules?"), true, N_('DB pending migration')),
      self.set('db_pending_seed', N_("Should the `foreman-rake db:seed` be executed on the next run of the installer modules?"), true, N_('DB pending seed')),
      self.set('proxy_request_timeout', N_("Max timeout for REST client requests to smart-proxy"), 60, N_('Proxy request timeout')),
      self.set('login_text', N_("Text to be shown in the login-page footer"), nil, N_('Login page footer text')),
      self.set('host_power_status', N_("Show power status on host index page. This feature calls to compute resource providers which may lead to decreased performance on host listing page."), true, N_('Show host power status')),
      self.set('http_proxy', N_('Sets a proxy for all outgoing HTTP connections.'), nil, N_('HTTP(S) proxy')),
      self.set('http_proxy_except_list', N_('Set hostnames to which requests are not to be proxied. Requests to the local host are excluded by default.'), [], N_('HTTP(S) proxy except hosts')),
      self.set('lab_features', N_("Whether or not to show a menu to access experimental lab features (requires reload of page)"), false, N_('Show Experimental Labs')),
      self.set("append_domain_name_for_hosts", N_("Foreman will append domain names when new hosts are provisioned"), true, N_("Append domain names to the host")),
      self.set('outofsync_interval', N_("Duration in minutes after servers are classed as out of sync."), 30, N_('Out of sync interval'))
    ]
  end

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      default_settings.each { |s| self.create! s.update(:category => "Setting::General")}
    end

    true
  end

  def self.humanized_category
    N_('General')
  end

  def validate_http_proxy(record)
    if record.value.present? && !is_http_url?(record.value)
      record.errors[:base] << _("Not a valid URL for a HTTP proxy")
    end
  end
end
