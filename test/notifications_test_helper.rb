# Create notification blueprints prior to tests
module NotificationBlueprintSeeds
  extend ActiveSupport::Concern

  included do
    setup :seed_notification_blueprints
  end

  def seed_notification_blueprints
    load File.join(Rails.root, 'db', 'seeds.d', '170-notification_blueprints.rb')
  end
end
