class UserMailNotification < ActiveRecord::Base
  attr_accessible :last_sent, :mail_notification_id, :user_id, :interval, :mail_query

  belongs_to :user
  belongs_to :mail_notification

  validates :user, :presence => true
  validates :mail_notification, :presence => true

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
