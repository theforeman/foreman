class Dashboard

  attr_reader :report
  # returns a status hash
  def self.status(filter="")
    new(filter).report
  end

  def initialize(filter="")
    @filter = filter
    @report = {}
    fetch_data
  end

  def systems
    @systems ||= System.my_systems.search_for(filter)
  end

  private
  attr_writer :report
  attr_accessor :filter
  def fetch_data
      report.update({
          :total_systems               => systems.count,
          :bad_systems                 => systems.recent.with_error.count,
          :bad_systems_enabled         => systems.recent.with_error.alerts_enabled.count,
          :active_systems              => systems.recent.with_changes.count,
          :active_systems_ok           => systems.recent.with_changes.without_error.count,
          :active_systems_ok_enabled   => systems.recent.with_changes.without_error.alerts_enabled.count,
          :ok_systems                  => systems.recent.successful.count,
          :ok_systems_enabled          => systems.recent.successful.alerts_enabled.count,
          :out_of_sync_systems         => systems.out_of_sync.count,
          :out_of_sync_systems_enabled => systems.out_of_sync.alerts_enabled.count,
          :disabled_systems            => systems.alerts_disabled.count,
          :pending_systems             => systems.recent.with_pending_changes.count,
          :pending_systems_enabled     => systems.recent.with_pending_changes.alerts_enabled.count,
      })
      report[:good_systems]         = report[:ok_systems]         + report[:active_systems_ok]
      report[:good_systems_enabled] = report[:ok_systems_enabled] + report[:active_systems_ok_enabled]
      report[:percentage]         = percentage
      report[:reports_missing]    = reports_missing
  end

  def percentage
    return 0 if report[:ok_systems_enabled] == 0 or report[:total_systems] == 0
    report[:ok_systems_enabled] * 100 / report[:total_systems]
  end

  def reports_missing
    systems.search_for('not has last_report and status.enabled = true').count
  end

end
