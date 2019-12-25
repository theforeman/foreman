# To add a new mail notification, you need at a minimum of name, title, mailer,
# and method, and need to define the corresponding ActionMailer and method.
# For system notifications, set subscriptable to false.  For recurring reports,
# set subscription_type to 'report', and for ad hoc mails, use 'alert'

# The names below are shown as humanized labels in the UI, so these should be
# localized
N_('Puppet summary')
N_('Welcome')
N_('Audit summary')
N_('Host built')
N_('Tester')
N_('Puppet error state')

notifications = [
  {
    :name              => 'config_summary',
    :description       => N_('A summary of eventful configuration management reports'),
    :mailer            => 'HostMailer',
    :method            => 'summary',
    :subscription_type => 'report',
  },

  {
    :name              => 'welcome',
    :description       => N_('A mail a user receives upon account creation'),
    :mailer            => 'UserMailer',
    :method            => 'welcome',
    :subscriptable     => false,
  },

  {
    :name               => 'audit_summary',
    :description        => N_('A summary of audit changes report <br> Filtered by a query if needed'),
    :mailer             => 'AuditMailer',
    :method             => 'summary',
    :subscription_type  => 'report',
    :queryable          => true,
  },

  {
    :name               => 'host_built',
    :description        => N_('A notification when a host finishes building'),
    :mailer             => 'HostMailer',
    :method             => 'host_built',
    :subscription_type  => 'alert',
  },

  {
    :name               => 'tester',
    :description        => N_('A test message to check the email configuration is working'),
    :mailer             => 'UserMailer',
    :method             => 'tester',
    :subscriptable      => false,
    :subscription_type  => nil,
  },

  {
    :name               => 'config_error_state',
    :description        => N_('A notification when a host reports a configuration error'),
    :mailer             => 'HostMailer',
    :method             => 'error_state',
    :subscription_type  => 'alert',
  },
]

notifications.each do |notification|
  if (mail = MailNotification.find_by_name(notification[:name]))
    mail.attributes = notification
    mail.save! if mail.changed?
  else
    created_notification = MailNotification.create(notification)
    if created_notification.nil? || created_notification.errors.any?
      raise ::Foreman::Exception.new(N_("Unable to create mail notification: %s"),
        format_errors(created_notification))
    end
  end
end
