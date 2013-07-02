require 'facter'
class Setting::General < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      domain = Facter.domain
      [
        self.set('administrator', N_("The default administrator email address"), "root@#{domain}"),
        self.set('foreman_url', N_(  "The hostname where your Foreman instance is reachable"), "foreman.#{domain}"),
        self.set('email_reply_address', N_("The email reply address for emails that Foreman is sending"), "Foreman-noreply@#{domain}"),
        self.set('entries_per_page', N_("The amount of records shown per page in Foreman"), 20),
        self.set('authorize_login_delegation', N_("Authorize login delegation with REMOTE_USER environment variable"),false),
        self.set('authorize_login_delegation_api', N_("Authorize login delegation with REMOTE_USER environment variable for API calls too"),false),
        self.set('idle_timeout', N_("Log out idle users after a certain number of minutes"),60),
        self.set('max_trend', N_("Max days for Trends graphs"),30),
        self.set('use_gravatar', N_("Should Foreman use gravatar to display user icons"),true)
      ].each { |s| self.create! s.update(:category => "Setting::General")}
    end

    true

  end

end
