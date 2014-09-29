# To add a new mail notification, you need at a minimum of name, title, mailer,
# and method, and need to define the corresponding ActionMailer and method.  To
# leverage the default cron jobs, ensure to set the default_interval to daily,
# weekly or monthly.  For system notifications, set subscriptable to false.

notifications = [
  {:name             => 'Puppet Daily Summary',
   :title            => :puppet_daily_summary,
   :description      => 'A daily summary of eventful puppet reports',
   :mailer           => 'HostMailer',
   :method           => 'summary',
   :default_interval => 'daily'
  },

 {:name             => 'Puppet Error State',
  :title            => :puppet_error_state,
  :description      => 'A notification when a host reports a puppet error',
  :mailer           => 'HostMailer',
  :method           => 'error_state'
 },

 {:name             => 'Welcome E-mail',
  :title            => :welcome,
  :description      => 'A mail a user receives upon account creation',
  :mailer           => 'UserMailer',
  :method           => 'welcome',
  :subscriptable    => false
 }
]

notifications.each do |notification|
  MailNotification.find_or_create_by_title(notification)
end
