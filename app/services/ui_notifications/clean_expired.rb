module UINotifications
  class CleanExpired
    def initialize(blueprint: nil, group: nil, expired_at: Time.now.utc)
      @blueprint = blueprint.present? ? {:notification_blueprints => {:name => blueprint }} : nil
      @group = group.present? ? {:notification_blueprints => {:group => group}} : nil
      expired_at = expired_at.to_time if expired_at.is_a?(String)
      raise(Foreman::Exception, 'Parsing expired time has failed') if expired_at.nil?
      raise(Foreman::Exception, 'Expired time cannot be greater then now') if expired_at > Time.now.utc
      @expired_at = expired_at
    end

    def clean!
      UINotifications::Base.logger.info("Removing all expired notifications")
      to_delete = Notification.joins(:notification_blueprint)
                      .where('notifications.expired_at < ?', @expired_at)
                      .where(@blueprint)
                      .where(@group)
      NotificationRecipient.where(notification: to_delete).delete_all
      @deleted_count = to_delete.delete_all
      self
    end

    def deleted_count
      raise 'cleaner has not cleaned anything yet, run #clean! first' if @deleted_count.nil?
      @deleted_count
    end
  end
end
