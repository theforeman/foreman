class Setting::Email < Setting
  NON_EMAIL_YAML_SETTINGS = %w(send_welcome_email email_reply_address email_subject_prefix)

  def self.default_settings
    domain = SETTINGS[:domain]
    email_reply_address = "foreman-noreply@#{domain}"

    [
      self.set('email_reply_address', N_("Email reply address for emails that Foreman is sending"), email_reply_address, N_('Email reply address')),
      self.set('email_subject_prefix', N_("Prefix to add to all outgoing email"), '[foreman]', N_('Email subject prefix')),
      self.set('send_welcome_email', N_("Send a welcome email including username and URL to new users"), false, N_('Send welcome email')),
      self.set('delivery_method', N_("Method used to deliver email"), 'sendmail', N_('Delivery method'), nil, { :collection => Proc.new {{:sendmail => _("Sendmail"), :smtp => _("SMTP")}}}),
      self.set('smtp_enable_starttls_auto', N_("SMTP automatic STARTTLS"), true, N_('SMTP enable StartTLS auto')),
      self.set('smtp_openssl_verify_mode', N_("When using TLS, you can set how OpenSSL checks the certificate"), '', N_('SMTP OpenSSL verify mode'), nil, { :collection => Proc.new {{'' => _("Default verification mode"), :none => _("none"), :peer => "peer", :client_once => "client_once", :fail_if_no_peer_cert => "fail_if_no_peer_cert"}}}),
      self.set('smtp_address', N_("Address to connect to"), '', N_('SMTP address')),
      self.set('smtp_port', N_("Port to connect to"), 25, N_('SMTP port')),
      self.set('smtp_domain', N_("HELO/EHLO domain"), '', N_('SMTP HELO/EHLO domain')),
      self.set('smtp_user_name', N_("Username to use to authenticate, if required"), '', N_('SMTP username')),
      self.set('smtp_password', N_("Password to use to authenticate, if required"), '', N_('SMTP password'), nil, {:encrypted => true}),
      self.set('smtp_authentication', N_("Specify authentication type, if required"), '', N_('SMTP authentication'), nil, { :collection => Proc.new {{:plain => "plain", :login => "login", :cram_md5 => "cram_md5", '' => _("none")}}}),
      self.set('sendmail_arguments', N_("Specify additional options to sendmail"), '-i', N_('Sendmail arguments')),
      self.set('sendmail_location', N_("The location of the sendmail executable"), "/usr/sbin/sendmail", N_('Sendmail location')),
    ]
  end

  validates :value, :length => {:maximum => 255}, :if => Proc.new { |s| s.name == "email_subject_prefix" }

  def self.delivery_settings
    options = {}
    self.all.find_each do |setting|
      extracted = {:smtp => extract_prefix(setting.name, 'smtp'), :sendmail => extract_prefix(setting.name, 'sendmail')}
      ["smtp", "sendmail"].each do |method|
        if Setting[:delivery_method].to_s == method && setting.name.start_with?(method) && setting.value.to_s.present?
          options[extracted[method.to_sym]] = setting.value
        end
      end
    end
    options
  end

  def self.extract_prefix(name, prefix)
    name.to_s.gsub(/^#{prefix}_/, '')
  end
end
