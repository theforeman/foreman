class Notification < ActiveRecord::Base
  belongs_to :notification_type
  belongs_to :initiator, :class_name => User, :foreign_key => 'user_id'
  belongs_to :subject, :polymorphic => true
  has_many :notification_recipients, :dependent => :delete_all
  has_many :recipients, :class_name => User, :through => :notification_recipients, :source => :user

  validates :notification_type, :presence => true
  validates :initiator, :presence => true
  validates :subject, :presence => true, :allow_nil => true
  before_create :calculate_expiry, :set_notification_recipients

  scope :active, -> { where('expired_at >= :now', {:now => Time.now.utc}) }
  scope :expired, -> { where('expired_at < :now', {:now => Time.now.utc}) }

  def expired?
    Time.now.utc > expired_at
  end

  private

  def calculate_expiry
    self.expired_at = Time.now.utc + notification_type.expires_in
  end

  def set_notification_recipients
    subscribers = notification_type.subscriber_ids(initiator, subject)
    self.notification_recipients.build subscribers.map{|id| { :user_id => id}}
  end
end
