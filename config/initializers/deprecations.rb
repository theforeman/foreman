ActiveSupport::Deprecation.behavior = :silence if Rails.env.production?

Foreman::Application.configure do |app|
  config.after_initialize do
    next if Foreman.in_rake?
    next unless Rails.env.production?
    next if SETTINGS[:unattended]
    blueprint = NotificationBlueprint.find_by_name('feature_deprecation')
    next unless blueprint
    message = UINotifications::StringParser.new(blueprint.message, {feature: 'Setting ":unattended: false" in settings.yaml', version: '3.3'}).to_s
    next if blueprint.notifications.where(message: message).any?
    Notification.create!(
      audience: Notification::AUDIENCE_ADMIN,
      message: message,
      notification_blueprint: blueprint,
      initiator: User.anonymous_admin,
      actions: {
        links: [
          {
            href: 'https://community.theforeman.org/t/rfc-remove-unattended-setting/10035',
            title: _('Further Information'),
            external: true,
          },
        ],
      }
    )
  end
end
