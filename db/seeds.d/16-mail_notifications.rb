# To add a new mail notification, you need at a minimum of name, title, mailer,
# and method, and need to define the corresponding ActionMailer and method.
# For system notifications, set subscriptable to false.  For recurring reports,
# set subscription_type to 'report', and for ad hoc mails, use 'alert'

notifications = [
  {:name              => :puppet_summary,
   :description       => N_('A summary of eventful puppet reports'),
   :mailer            => 'HostMailer',
   :method            => 'summary',
   :subscription_type => 'report'
  },

  {:name              => :puppet_error_state,
   :description       => N_('A notification when a host reports a puppet error'),
   :mailer            => 'HostMailer',
   :method            => 'error_state',
   :subscription_type => 'alert'
  },

  {:name              => :welcome,
   :description       => N_('A mail a user receives upon account creation'),
   :mailer            => 'UserMailer',
   :method            => 'welcome',
   :subscriptable     => false
 }
]

notifications.each do |notification|
  MailNotification.find_or_create_by_name(notification)
end

