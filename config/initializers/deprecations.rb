ActiveSupport::Deprecation.behavior = :silence if Rails.env.production?

Foreman::Application.configure do |app|
  config.after_initialize do
    next if Foreman.in_rake?
    next unless Rails.env.production?
    next unless ComputeResource.all.unscoped.map { |cr| cr.class == Foreman::Model::Rackspace }.include? true
    blueprint = NotificationBlueprint.find_by_name('feature_deprecation')
    next unless blueprint
    message = UINotifications::StringParser.new(blueprint.message, {feature: 'Rackspace Compute Resource', version: '2.0'}).to_s
    next if blueprint.notifications.where(message: message).any?
    Notification.create!(
      audience: Notification::AUDIENCE_ADMIN,
      message: message,
      notification_blueprint: blueprint,
      initiator: User.anonymous_admin,
      :actions => {
        :links => [
          {
            :href => 'https://community.theforeman.org/t/dropping-rackspace-compute-resource-from-foreman-core/17690',
            :title => _('Further Information'),
            :external => true,
          },
        ],
      }
    )
  end
end
