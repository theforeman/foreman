module UINotifications
  class CacheHandler
    def initialize(user_id = User.current.try(:id))
      raise(Foreman::Exception, 'must provide user_id') if user_id.nil?
      @user_id = user_id
    end

    # JSON Payload
    def payload
      result = cache.read(cache_key)
      if result
        logger.debug("Cache Hit: notification, reading cache for #{cache_key}")
        return result
      end

      result = { notifications: notifications }.to_json

      logger.debug("Cache Miss: notification, writing cache for #{cache_key}")
      cache.write(cache_key, result, { raw: true, expires_in: cache_expiry })

      result
    end

    def clear
      logger.debug("Clearing Cache: notification, clearing cache for #{cache_key}")
      cache.delete(cache_key)
    end

    private

    def logger
      @logger ||= Foreman::Logging.logger('notifications')
    end

    delegate :cache, to: Rails
    attr_reader :user_id

    def notifications
      @notifications ||= NotificationRecipient.
        where(user_id: user_id, notification_id: Notification.active).
        order(created_at: :desc).
        limit(100).
        preload(:notification, :notification_blueprint).
        map(&:payload)
    end

    def cache_key
      "notification-#{user_id}".freeze
    end

    def cache_expiry
      next_expiry = Notification.
        active.
        joins(:notification_recipients).
        where(notification_recipients: {user_id: user_id}).
        minimum(:expired_at)

      result = next_expiry.nil? ? default_cache_expiry : next_expiry - Time.now.utc

      logger.debug("Expiring notification cache #{cache_key} in #{result} seconds")
      result
    end

    def default_cache_expiry
      1.hour
    end
  end
end
