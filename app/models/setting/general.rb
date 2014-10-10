require 'facter'
class Setting::General < Setting

  def self.load_defaults
    # Check the table exists
    return unless super
    protocol = SETTINGS[:require_ssl] ? 'https' : 'http'
    domain = Facter.value(:domain) || SETTINGS[:domain]
    administrator = "root@#{domain}"
    foreman_url = "#{protocol}://#{Facter.value(:fqdn) || SETTINGS[:fqdn]}"
    email_reply_address = "Foreman-noreply@#{domain}"

    self.transaction do
      [
        self.set('administrator', N_("The default administrator email address"), administrator),
        self.set('foreman_url', N_("URL where your Foreman instance is reachable (see also Provisioning > unattended_url)"), foreman_url),
        self.set('email_reply_address', N_("Email reply address for emails that Foreman is sending"), email_reply_address),
        self.set('entries_per_page', N_("Number of records shown per page in Foreman"), 20),
        self.set('fix_db_cache', N_('Fix DB cache on next Foreman restart'), false),
        self.set('authorize_login_delegation', N_("Authorize login delegation with REMOTE_USER environment variable"), false),
        self.set('authorize_login_delegation_api', N_("Authorize login delegation with REMOTE_USER environment variable for API calls too"), false),
        self.set('idle_timeout', N_("Log out idle users after a certain number of minutes"), 60),
        self.set('max_trend', N_("Max days for Trends graphs"), 30),
        self.set('use_gravatar', N_("Foreman will use gravatar to display user icons"), true),
        self.set('db_pending_migration', N_("Should the `foreman-rake db:migrate` be executed on the next run of the installer modules?"), true),
        self.set('db_pending_seed', N_("Should the `foreman-rake db:seed` be executed on the next run of the installer modules?"), true),
        self.set('proxy_request_timeout', N_("Max timeout for REST client requests to smart-proxy"), 60)
      ].each { |s| self.create! s.update(:category => "Setting::General")}
    end

    true

  end

end
