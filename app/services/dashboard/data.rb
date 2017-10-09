class Dashboard::Data
  attr_reader :filter
  # returns a status hash
  def self.status(filter = "")
    new(filter).report
  end

  def initialize(filter = "")
    @filter = filter
    @report = {}
  end

  def hosts
    @hosts ||= Host.authorized(:view_hosts, Host).search_for(filter).reorder('')
  end

  def report
    fetch_data if @report.blank?
    @report
  end

  def latest_events
    # 9 reports + header fits the events box nicely...
    @latest_events ||= ConfigReport.authorized(:view_config_reports).my_reports.interesting
                                   .where(host_id: hosts.pluck(:id))
                                   .search_for('reported > "7 days ago"')
                                   .reorder(:reported_at => :desc)
                                   .limit(9)
                                   .preload(:host)
  end

  def latest_events?
    #exists? removes the order field causing the db to use the wrong index
    latest_events.limit(1).present?
  end

  private
  def fetch_data
    @report.update(
      {  :total_hosts               => hosts.size,
         :bad_hosts                 => hosts.recent.with_error.count,
         :bad_hosts_enabled         => hosts.recent.with_error.alerts_enabled.count,
         :active_hosts              => hosts.recent.with_changes.count,
         :active_hosts_ok           => hosts.recent.with_changes.without_error.count,
         :active_hosts_ok_enabled   => hosts.recent.with_changes.without_error.alerts_enabled.count,
         :ok_hosts                  => hosts.recent.successful.count,
         :ok_hosts_enabled          => hosts.recent.successful.alerts_enabled.count,
         :out_of_sync_hosts         => hosts.out_of_sync.count,
         :out_of_sync_hosts_enabled => hosts.out_of_sync.alerts_enabled.count,
         :disabled_hosts            => hosts.alerts_disabled.count,
         :pending_hosts             => hosts.recent.with_pending_changes.count,
         :pending_hosts_enabled     => hosts.recent.with_pending_changes.alerts_enabled.count
      })
    @report[:good_hosts]         = @report[:ok_hosts]         + @report[:active_hosts_ok]
    @report[:good_hosts_enabled] = @report[:ok_hosts_enabled] + @report[:active_hosts_ok_enabled]
    @report[:percentage]         = percentage
    @report[:reports_missing]    = reports_missing
  end

  def percentage
    return 0 if @report[:ok_hosts_enabled] == 0 || @report[:total_hosts] == 0
    @report[:ok_hosts_enabled] * 100 / @report[:total_hosts]
  end

  def reports_missing
    hosts.search_for('not has last_report and status.enabled = true').count
  end
end
