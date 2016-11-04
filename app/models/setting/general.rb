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
        self.set('administrator', N_("The default administrator email address"), administrator, N_('Administrator email address')),
        self.set('foreman_url', N_("URL where your Foreman instance is reachable (see also Provisioning > unattended_url)"), foreman_url, N_('Foreman URL')),
        self.set('email_reply_address', N_("Email reply address for emails that Foreman is sending"), email_reply_address, N_('Email reply address')),
        self.set('email_subject_prefix', N_("Prefix to add to all outgoing email"), '[foreman]', N_('Email subject prefix')),
        self.set('send_welcome_email', N_("Send a welcome email including username and URL to new users"), false, N_('Send welcome email')),
        self.set('entries_per_page', N_("Number of records shown per page in Foreman"), 20, N_('Entries per page')),
        self.set('fix_db_cache', N_('Fix DB cache on next Foreman restart'), false, N_('Fix DB cache')),
        self.set('max_trend', N_("Max days for Trends graphs"), 30, N_('Max trends')),
        self.set('use_gravatar', N_("Foreman will use gravatar to display user icons"), false, N_('Use Gravatar')),
        self.set('db_pending_migration', N_("Should the `foreman-rake db:migrate` be executed on the next run of the installer modules?"), true, N_('DB pending migration')),
        self.set('db_pending_seed', N_("Should the `foreman-rake db:seed` be executed on the next run of the installer modules?"), true, N_('DB pending seed')),
        self.set('proxy_request_timeout', N_("Max timeout for REST client requests to smart-proxy"), 60, N_('Proxy request timeout')),
        self.set('login_text', N_("Text to be shown in the login-page footer"), nil, N_('Login page footer text'))
      ].each { |s| self.create! s.update(:category => "Setting::General")}
    end

    true
  end

  def self.humanized_category
    N_('General')
  end
end
