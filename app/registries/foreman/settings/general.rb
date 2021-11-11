Foreman::SettingManager.define(:foreman) do
  locales = -> { Hash['' => _("Browser locale")].merge(Hash[FastGettext.human_available_locales.map { |lang| [lang[1], lang[0]] }]) }
  timezones = -> { Hash['' => _("Browser timezone")].merge(Hash[ActiveSupport::TimeZone.all.map { |tz| [tz.name, "(GMT #{tz.formatted_offset}) #{tz.name}"] }]) }

  category(:general, N_('General')) do
    setting('administrator',
      type: :string,
      description: N_("The default administrator email address"),
      default: "root@#{SETTINGS[:domain]}",
      full_name: N_('Administrator email address'),
      validate: :email)
    setting('foreman_url',
      type: :string,
      description: N_("URL where your Foreman instance is reachable (see also Provisioning > unattended_url)"),
      default: "#{SETTINGS[:require_ssl] ? 'https' : 'http'}://#{SETTINGS[:fqdn]}",
      full_name: N_('Foreman URL'),
      validate: :http_url)
    setting('entries_per_page',
      type: :integer,
      description: N_("Number of records shown per page in Foreman"),
      default: 20,
      full_name: N_('Entries per page'))
    setting('db_pending_seed',
      type: :boolean,
      description: N_("Should the `foreman-rake db:seed` be executed on the next run of the installer modules?"),
      default: true,
      full_name: N_('DB pending seed'))
    setting('proxy_request_timeout',
      type: :integer,
      description: N_("Open and read timeout for HTTP requests from Foreman to Smart Proxy (in seconds)"),
      default: 60,
      full_name: N_('Smart Proxy request timeout'))
    setting('login_text',
      type: :text,
      description: N_("Text to be shown in the login-page footer"),
      default: nil,
      full_name: N_('Login page footer text'))
    setting('host_power_status',
      type: :boolean,
      description: N_("Show power status on host index page. This feature calls to compute resource providers which may lead to decreased performance on host listing page."),
      default: true,
      full_name: N_('Show host power status'))
    setting('http_proxy',
      type: :string,
      description: N_('Set a proxy for all outgoing HTTP(S) connections from Foreman. System-wide proxies must be configured at the operating system level.'),
      default: nil,
      full_name: N_('HTTP(S) proxy'))
    validates :http_proxy, http_url: { allow_blank: true }
    setting('http_proxy_except_list',
      type: :array,
      description: N_('Set hostnames to which requests are not to be proxied. Requests to the local host are excluded by default.'),
      default: [],
      full_name: N_('HTTP(S) proxy except hosts'))
    setting('lab_features',
      type: :boolean,
      description: N_("Whether or not to show a menu to access experimental lab features (requires reload of page)"),
      default: false,
      full_name: N_('Show Experimental Labs'))
    setting('append_domain_name_for_hosts',
      type: :boolean,
      description: N_('Foreman will append domain names when new hosts are provisioned'),
      default: true,
      full_name: N_('Append domain names to the host'))
    setting('outofsync_interval',
      type: :integer,
      description: N_('Duration in minutes after servers are classed as out of sync. You can override this on hosts by adding a parameter "outofsync_interval".'),
      default: 30,
      full_name: N_('Out of sync interval'))
    setting('instance_id',
      type: :string,
      description: N_("Foreman instance ID, uniquely identifies this Foreman instance."),
      default: 'uuid',
      full_name: N_('Foreman UUID'),
      value: Foreman.uuid)
    setting('default_locale',
      type: :string,
      description: N_("Language to use for new users"),
      default: nil,
      full_name: N_('Default language'),
      collection: locales)
    setting('default_timezone',
      type: :string,
      description: N_("Timezone to use for new users"),
      default: nil,
      full_name: N_('Default timezone'),
      collection: timezones)
    setting('instance_title',
      type: :string,
      description: N_("The instance title is shown on the top navigation bar (requires a page reload)."),
      default: nil,
      full_name: N_('Instance title'))
    setting('audits_period',
      type: :integer,
      description: N_('Duration in days to preserve audits for. Leave empty to disable the audits cleanup.'),
      default: nil,
      full_name: N_('Saved audits interval'))
    setting('host_details_ui',
      type: :boolean,
      description: N_("Foreman will load the new UI for host details"),
      default: false,
      full_name: N_('New host details UI'))
  end
end
