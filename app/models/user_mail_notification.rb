class UserMailNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :mail_notification

  #validates :user_id, :presence => true
  validates :mail_notification, :presence => true

  scope :daily, lambda { where(:interval => 'Daily') }
  scope :weekly,  lambda { where(:interval => 'Weekly') }
  scope :monthly, lambda { where(:interval => 'Monthly') }

  def deliver(options = {})
    return unless user.mail_enabled?
    options[:time] = last_sent if last_sent
    options[:query] = mail_query if mail_query
    mail_notification.deliver(options.merge(:user => user.id))
    update_attribute(:last_sent, Time.zone.now)
  end
end
