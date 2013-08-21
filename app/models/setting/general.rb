require 'facter'
class Setting::General < Setting

  def self.load_defaults
    # Check the table exists
    return unless super

    self.transaction do
      domain = Facter.domain
      Setting::General.init_on_startup!('administrator', N_("The default administrator email address"), "root@#{domain}")
      Setting::General.init_on_startup!('foreman_url', N_(  "The hostname where your Foreman instance is reachable"), "foreman.#{domain}")
      Setting::General.init_on_startup!('email_reply_address', N_("The email reply address for emails that Foreman is sending"), "Foreman-noreply@#{domain}")
      Setting::General.init_on_startup!('entries_per_page', N_("The amount of records shown per page in Foreman"), 20)
      Setting::General.init_on_startup!('authorize_login_delegation', N_("Authorize login delegation with REMOTE_USER environment variable"),false)
      Setting::General.init_on_startup!('authorize_login_delegation_api', N_("Authorize login delegation with REMOTE_USER environment variable for API calls too"),false)
      Setting::General.init_on_startup!('idle_timeout', N_("Log out idle users after a certain number of minutes"),60)
      Setting::General.init_on_startup!('max_trend', N_("Max days for Trends graphs"),30)
      Setting::General.init_on_startup!('use_gravatar', N_("Should Foreman use gravatar to display user icons"),true)
    end
    true
  end

end
