class PuppetError < MailNotification
  scope :all_hosts, -> { PuppetError.includes(:user_mail_notifications).where(:user_mail_notifications => {:interval => 'Subscribe to all hosts'}) }

  def subscription_options
    [N_("Subscribe to my hosts"), N_("Subscribe to all hosts")]
  end
end
