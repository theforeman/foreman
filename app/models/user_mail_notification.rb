class UserMailNotification < ActiveRecord::Base
  attr_accessible :last_sent, :mail_notification_id, :user_id, :interval

  belongs_to :user
  belongs_to :mail_notification

  validates :user_id, :presence => true
  validates :mail_notification, :presence => true

  scope :daily, lambda { where(:interval => 'Daily') }
  scope :weekly,  lambda { where(:interval => 'Weekly') }
  scope :monthly, lambda { where(:interval => 'Monthly') }

  def deliver(options = {})
    return unless user.mail_enabled?
    options[:time] = last_sent if last_sent
    mail_notification.deliver(options.merge(:user => user.id))
    update_attribute(:last_sent, Time.now)
  end
end
