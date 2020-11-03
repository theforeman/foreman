class StoredValuesCleanupJob < ApplicationJob
  include ::Foreman::ObservableJob
  set_hook :stored_values_cleanup_performed

  def perform(options = {})
    StoredValue.expired(options[:ago] || 0).destroy_all
  ensure
    self.class.set(:wait => 12.hours).perform_later(options)
  end

  rescue_from(StandardError) do |error|
    Foreman::Logging.logger('background').error(
      'StoredValues cleanup: '\
      "Error while cleaning up stored_values table - #{error.message}")
    raise error # propagate the error to the tasking system to properly report it there
  end

  def humanized_name
    _('Clean up StoredValues')
  end
end
