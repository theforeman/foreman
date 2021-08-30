module Dashboard
  class Data
    attr_reader :filter, :settings

    # returns a status hash
    def self.status(filter = "")
      new(filter).report
    end

    def initialize(filter = "", settings = nil)
      @filter = filter
      @report = {}
      @settings = settings || {}
    end

    def hosts
      @hosts ||= Host.authorized(:view_hosts, Host).search_for(filter).reorder('')
      @hosts = @hosts.with_last_report_origin(settings[:origin]) if settings[:origin] && settings[:origin] != 'All'
      @hosts
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
      # exists? removes the order field causing the db to use the wrong index
      latest_events.limit(1).present?
    end

    private

    def fetch_data
      @report.update(
        :total_hosts               => hosts.size,
        :bad_hosts                 => recent_hosts_or_hosts.with_error.count,
        :bad_hosts_enabled         => recent_hosts_or_hosts.with_error.alerts_enabled.count,
        :active_hosts              => recent_hosts_or_hosts.with_changes.count,
        :active_hosts_ok           => recent_hosts_or_hosts.with_changes.without_error.count,
        :active_hosts_ok_enabled   => recent_hosts_or_hosts.with_changes.without_error.alerts_enabled.count,
        :ok_hosts                  => recent_hosts_or_hosts.successful.count,
        :ok_hosts_enabled          => recent_hosts_or_hosts.successful.alerts_enabled.count,
        :disabled_hosts            => hosts.alerts_disabled.count,
        :pending_hosts             => recent_hosts_or_hosts.with_pending_changes.count,
        :pending_hosts_enabled     => recent_hosts_or_hosts.with_pending_changes.alerts_enabled.count
      )
      if out_of_sync_enabled?
        @report.update(
          :out_of_sync_hosts => out_of_sync_hosts.count,
          :out_of_sync_hosts_enabled => out_of_sync_hosts.alerts_enabled.count
        )
      end
      @report[:good_hosts]         = @report[:ok_hosts]         + @report[:active_hosts_ok]
      @report[:good_hosts_enabled] = @report[:ok_hosts_enabled] + @report[:active_hosts_ok_enabled]
      @report[:percentage]         = percentage
      @report[:reports_missing]    = reports_missing
    end

    def out_of_sync_hosts
      if settings[:origin] && settings[:origin] != 'All'
        hosts.out_of_sync_for(settings[:origin])
      else
        hosts.out_of_sync
      end
    end

    def recent_hosts_or_hosts
      out_of_sync_enabled? ? recent_hosts : hosts
    end

    def recent_hosts
      if settings[:origin] && settings[:origin] != 'All'
        hosts.recent(Setting[:"#{settings[:origin].downcase}_interval"], settings[:origin])
      else
        hosts.recent
      end
    end

    def percentage
      return 0 if @report[:ok_hosts_enabled] == 0 || @report[:total_hosts] == 0
      @report[:ok_hosts_enabled] * 100 / @report[:total_hosts]
    end

    def reports_missing
      hosts.search_for('not has last_report and status.enabled = true').count
    end

    def out_of_sync_enabled?
      return true unless settings[:origin]
      setting = Setting[:"#{settings[:origin].downcase}_out_of_sync_disabled"]
      setting.nil? ? true : !setting
    end
  end
end
