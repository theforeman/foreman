ActiveSupport::Deprecation.behavior = :silence if Rails.env.production?

Foreman::Application.configure do |app|
  config.after_initialize do
    next if Foreman.in_rake?
    next unless ActiveRecord::Base.connection.adapter_name.downcase.starts_with?('mysql')
    blueprint = NotificationBlueprint.find_by(name: 'feature_deprecation')
    next unless blueprint
    message = UINotifications::StringParser.new(blueprint.message, {feature: 'MySQL as a backend database', version: '1.25'}).to_s
    next if blueprint.notifications.where(message: message).any?
    Notification.create!(
      audience: Notification::AUDIENCE_ADMIN,
      message: message,
      notification_blueprint: blueprint,
      initiator: User.anonymous_admin,
      :actions => {
        :links => [
          {
            :href => 'https://theforeman.org/2019/09/dropping-support-for-mysql.html',
            :title => _('Further Information'),
            :external => true,
          },
        ],
      }
    )
  end
end

Foreman::Application.configure do |app|
  config.after_initialize do
    next if Foreman.in_rake?
    next unless Rails.env.production?
    next unless ActiveRecord::Base.connection.adapter_name.downcase.starts_with?('sqlite')
    blueprint = NotificationBlueprint.find_by(name: 'feature_deprecation')
    next unless blueprint
    message = UINotifications::StringParser.new(blueprint.message, {feature: 'SQLite as a production database', version: '1.25'}).to_s
    next if blueprint.notifications.where(message: message).any?
    Notification.create!(
      audience: Notification::AUDIENCE_ADMIN,
      message: message,
      notification_blueprint: blueprint,
      initiator: User.anonymous_admin,
      :actions => {
        :links => [
          {
            :href => 'https://community.theforeman.org/t/dropping-support-for-sqlite-as-production-database/16158',
            :title => _('Further Information'),
            :external => true,
          },
        ],
      }
    )
  end
end

Foreman::Application.configure do |app|
  config.after_initialize do
    next if Foreman.in_rake?
    next unless VariableLookupKey.any?
    blueprint = NotificationBlueprint.find_by(name: 'feature_deprecation')
    next unless blueprint
    message = UINotifications::StringParser.new(blueprint.message, {feature: 'Smart Variables', version: '2.0'}).to_s
    next if blueprint.notifications.where(message: message).any?
    Notification.create!(
      audience: Notification::AUDIENCE_ADMIN,
      message: message,
      notification_blueprint: blueprint,
      initiator: User.anonymous_admin,
      :actions => {
        :links => [
          {
            :href => 'https://community.theforeman.org/t/dropping-smart-variables/16176',
            :title => _('Further Information'),
            :external => true,
          },
        ],
      }
    )
  end
end
