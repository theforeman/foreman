class NotificationRecipient < ApplicationRecord
  belongs_to :notification
  belongs_to :user
  has_one :notification_blueprint, :through => :notification

  validates :notification, :presence => true
  validates :user, :presence => true

  scope :unseen, -> { where(:seen => false) }
  after_commit :delete_user_cache

  def payload
    {
      :id         => id,
      :seen       => seen,
      :level      => notification_blueprint.level,
      :text       => notification.message,
      :created_at => notification.created_at.utc,
      :group      => notification_blueprint.group,
      :actions    => notification.actions,
    }
  end

  def current_user?
    User.current.id == user_id
  end

  private

  def delete_user_cache
    cache_handler = UINotifications::CacheHandler.new(user_id)
    cache_handler.clear

    # Broadcast notification update via Action Cable
    begin
      payload_json = cache_handler.payload
      user = User.unscoped.find_by(id: user_id)

      if user
        NotificationChannel.broadcast_to(user, { payload: payload_json })
      end
    rescue => e
      # Don't let broadcast errors break notification system
      Rails.logger.error("Failed to broadcast notification update: #{e.message}")
    end
  end
end
