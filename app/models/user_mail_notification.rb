class UserMailNotification < ActiveRecord::Base
  attr_accessible :last_sent, :mail_notification_id, :user_id, :interval

  belongs_to :user
  belongs_to :mail_notification

  validates :user, :presence => true
  validates :mail_notification, :presence => true

  scope :daily, lambda { where(:interval => 'daily') }
  scope :weekly,  lambda { where(:interval => 'weekly') }
  scope :monthly, lambda { where(:interval => 'monthly') }

  before_save :set_interval

  def deliver(options = {})
    options[:time] = last_sent if last_sent
    mail_notification.deliver(options.merge(:user => user))
    update_attribute(:last_sent, Time.now)
  end

  def set_interval
    self.interval = mail_notification.default_interval if interval.blank?
  end
end
