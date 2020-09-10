class UserMailNotification < ApplicationRecord
  belongs_to :user, :inverse_of => :user_mail_notifications
  belongs_to :mail_notification, :inverse_of => :user_mail_notifications

  scope :daily, -> { where(:interval => 'Daily') }
  scope :weekly, -> { where(:interval => 'Weekly') }
  scope :monthly, -> { where(:interval => 'Monthly') }

  def deliver(options = {})
    return unless user.mail_enabled?
    options[:time] = last_sent if last_sent
    options[:query] = mail_query if mail_query
    mail_notification.deliver(options.merge(:user => user.id))
    update_attribute(:last_sent, Time.zone.now)
  end
end
