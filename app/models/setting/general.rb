class Setting::General < Setting
  include UrlValidation

  # Lazy-load this to avoid loading this during Rails startup
  def self.locales
    Hash['' => _("Browser locale")].merge(Hash[FastGettext.human_available_locales.map { |lang| [lang[1], lang[0]] }])
  end

  # Lazy-load this to avoid loading this during Rails startup
  def self.timezones
    Hash['' => _("Browser timezone")].merge(Hash[ActiveSupport::TimeZone.all.map { |tz| [tz.name, "(GMT #{tz.formatted_offset}) #{tz.name}"] }])
  end

  def self.default_settings
    protocol = SETTINGS[:require_ssl] ? 'https' : 'http'
    domain = SETTINGS[:domain]
    administrator = "root@#{domain}"
    foreman_url = "#{protocol}://#{SETTINGS[:fqdn]}"

    [
      set('administrator', N_("The default administrator email address"), administrator, N_('Administrator email address')),
      set('foreman_url', N_("URL where your Foreman instance is reachable (see also Provisioning > unattended_url)"), foreman_url, N_('Foreman URL')),
      set('entries_per_page', N_("Number of records shown per page in Foreman"), 20, N_('Entries per page')),
      set('fix_db_cache', N_('Fix DB cache on next Foreman restart'), false, N_('Fix DB cache')),
      set('db_pending_seed', N_("Should the `foreman-rake db:seed` be executed on the next run of the installer modules?"), true, N_('DB pending seed')),
      set('proxy_request_timeout', N_("Open and read timeout for HTTP requests from Foreman to Smart Proxy (in seconds)"), 60, N_('Smart Proxy request timeout')),
      set('login_text', N_("Text to be shown in the login-page footer"), nil, N_('Login page footer text')),
      set('host_power_status', N_("Show power status on host index page. This feature calls to compute resource providers which may lead to decreased performance on host listing page."), true, N_('Show host power status')),
      set('http_proxy', N_('Sets a proxy for all outgoing HTTP connections from Foreman. System-wide proxies must be configured at operating system level.'), nil, N_('HTTP(S) proxy')),
      set('http_proxy_except_list', N_('Set hostnames to which requests are not to be proxied. Requests to the local host are excluded by default.'), [], N_('HTTP(S) proxy except hosts')),
      set('lab_features', N_("Whether or not to show a menu to access experimental lab features (requires reload of page)"), false, N_('Show Experimental Labs')),
      set("append_domain_name_for_hosts", N_("Foreman will append domain names when new hosts are provisioned"), true, N_("Append domain names to the host")),
      set('outofsync_interval', N_('Duration in minutes after servers are classed as out of sync. You can override this on hosts by adding a parameter "outofsync_interval".'), 30, N_('Out of sync interval')),
      set('instance_id', N_("Foreman instance ID, uniquely identifies this Foreman instance."), 'uuid', N_('Foreman UUID'), Foreman.uuid),
      set('default_locale', N_("Language to use for new users"), nil, N_('Default language'), nil, { :collection => proc { locales } }),
      set('default_timezone', N_("Timezone to use for new users"), nil, N_('Default timezone'), nil, { :collection => proc { timezones } }),
      set('instance_title', N_("The instance title is shown on the top navigation bar (requires reload of page)."), nil, N_('Instance title')),
    ]
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
