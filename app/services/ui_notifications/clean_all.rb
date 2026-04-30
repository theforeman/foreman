module UINotifications
  class CleanAll
    def initialize(blueprint: nil)
      @blueprint = blueprint.presence
    end

    def clean!
      UINotifications::Base.logger.info("Removing #{@blueprint || 'all'} notifications")
      scope = Notification.joins(:notification_blueprint)
      scope = scope.where(notification_blueprints: { name: @blueprint }) if @blueprint
      @deleted_count = scope.destroy_all.size
      self
    end

    def deleted_count
      raise 'cleaner has not cleaned anything yet, run #clean! first' if @deleted_count.nil?
      @deleted_count
    end
  end
end
