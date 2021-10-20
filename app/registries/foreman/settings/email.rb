Foreman::SettingManager.define(:foreman) do
  category(:email, N_('Email')) do
    SENDMAIL_LOCATIONS = %w(/usr/sbin/sendmail /usr/bin/sendmail /usr/local/sbin/sendmail /usr/local/bin/sendmail)

    setting('email_reply_address',
      type: :string,
      description: N_("Email reply address for emails that Foreman is sending"),
      default: "foreman-noreply@#{SETTINGS[:domain]}",
      full_name: N_('Email reply address'),
      validates: :email)
    setting('email_subject_prefix',
      type: :string,
      description: N_("Prefix to add to all outgoing email"),
      default: '[foreman]',
      full_name: N_('Email subject prefix'))
    setting('send_welcome_email',
      type: :boolean,
      description: N_("Send a welcome email including username and URL to new users"),
      default: false,
      full_name: N_('Send welcome email'))
    setting('delivery_method',
      type: :string,
      description: N_("Method used to deliver email"),
      default: 'sendmail',
      full_name: N_('Delivery method'),
      collection: proc { {:sendmail => _("Sendmail"), :smtp => _("SMTP")} })
    setting('smtp_enable_starttls_auto',
      type: :boolean,
      description: N_("SMTP automatic STARTTLS"),
      default: true,
      full_name: N_('SMTP enable StartTLS auto'))
    setting('smtp_openssl_verify_mode',
      type: :string,
      description: N_("When using TLS, you can set how OpenSSL checks the certificate"),
      default: '',
      full_name: N_('SMTP OpenSSL verify mode'),
      collection: proc { {'' => _("Default verification mode"), :none => _("none"), :peer => "peer", :client_once => "client_once", :fail_if_no_peer_cert => "fail_if_no_peer_cert"} })
    setting('smtp_address',
      type: :string,
      description: N_("SMTP address to connect to"),
      default: '',
      full_name: N_('SMTP address'))
    setting('smtp_port',
      type: :integer,
      description: N_("SMTP port to connect to"),
      default: 25,
      full_name: N_('SMTP port'))
    setting('smtp_domain',
      type: :string,
      description: N_("HELO/EHLO domain"),
      default: '',
      full_name: N_('SMTP HELO/EHLO domain'))
    setting('smtp_user_name',
      type: :string,
      description: N_("Username to use to authenticate, if required"),
      default: '',
      full_name: N_('SMTP username'))
    setting('smtp_password',
      type: :string,
      description: N_("Password to use to authenticate, if required"),
      default: '',
      full_name: N_('SMTP password'),
      encrypted: true)
    setting('smtp_authentication',
      type: :string,
      description: N_("Specify authentication type, if required"),
      default: '',
      full_name: N_('SMTP authentication'),
      collection: proc { {:plain => "plain", :login => "login", :cram_md5 => "cram_md5", '' => _("none")} })
    setting('sendmail_arguments',
      type: :string,
      description: N_("Specify additional options to sendmail. Only used when the delivery method is set to sendmail."),
      default: '-i',
      full_name: N_('Sendmail arguments'))
    setting('sendmail_location',
      type: :string,
      description: N_("The location of the sendmail executable. Only used when the delivery method is set to sendmail."),
      default: "/usr/sbin/sendmail",
      full_name: N_('Sendmail location'),
      collection: proc { SENDMAIL_LOCATIONS.zip(SENDMAIL_LOCATIONS).to_h })

    validates 'email_subject_prefix', length: { maximum: 255 }
    validates 'sendmail_location', ->(value) { value.blank? || SENDMAIL_LOCATIONS.include?(value) }, message: N_("Invalid sendmail location, use settings.yaml for arbitrary location")
  end
end
