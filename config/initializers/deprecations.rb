ActiveSupport::Deprecation.behavior = :silence if Rails.env.production?

Foreman::Application.configure do |app|
  config.after_initialize do
    next if Foreman.in_rake?
    next unless Rails.env.production?
    next unless ComputeResource.all.unscoped.where(type: 'Foreman::Model::Ovirt').any? { |cr| cr.use_v4 == false }
    blueprint = NotificationBlueprint.find_by_name('feature_deprecation')
    next unless blueprint
    message = UINotifications::StringParser.new(blueprint.message, {feature: 'Ovirt V3 API', version: '2.4'}).to_s
    next if blueprint.notifications.where(message: message).any?
    Notification.create!(
      audience: Notification::AUDIENCE_ADMIN,
      message: message,
      notification_blueprint: blueprint,
      initiator: User.anonymous_admin,
      actions: {
        links: [
          {
            href: 'https://community.theforeman.org/t/suggestion-to-drop-ovirt-api-v3-from-foreman/19915',
            title: _('Further Information'),
            external: true,
          },
        ],
      }
    )
  end
end
