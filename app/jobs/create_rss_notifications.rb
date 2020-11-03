class CreateRssNotifications < ApplicationJob
  include ::Foreman::ObservableJob
  set_hook :create_rss_notifications_performed

  def perform(options = {})
    # Defaults to theforeman.org blog RSS
    UINotifications::RssNotificationsChecker.new(options).deliver!
  ensure
    self.class.set(:wait => 12.hours).perform_later(options.reject { |k| k.to_s =~ /^_aj_/ })
  end

  rescue_from(StandardError) do |error|
    Foreman::Logging.logger('background').error(
      'RSS notification checker: '\
      "Error while creating notifications #{error.message}")
    raise error # propagate the error to the tasking system to properly report it there
  end

  def humanized_name
    _('Create RSS notifications')
  end
end
