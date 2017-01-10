class NotificationRecipient < ActiveRecord::Base
  belongs_to :notification
  has_one :notification_type, :through => :notification
  belongs_to :user

  validates :notification, :presence => true
  validates :user, :presence => true

  scope :unseen, -> { where(:seen => false) }

  def payload
    {
      :id         => id,
      :level      => notification_type.level,
      :created_at => notification.created_at,
      :text       => notification_type.message,
      :seen       => seen
    }
  end
end
