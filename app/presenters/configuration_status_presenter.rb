class ConfigurationStatusPresenter < HostStatusPresenter
  private

  delegate :connection, to: ActiveRecord::Base
  delegate :exec_query, to: :connection

  def total_data
    @total_data ||= exec_query(total_data_query.to_sql)
      .rows
      .each_with_object({}) { |(status, count), memo| memo[status] = count }
  end

  def owned_data
    @owned_data ||= exec_query(owned_data_query.to_sql)
      .rows
      .each_with_object({}) { |(status, count), memo| memo[status] = count }
  end

  def total_data_query
    host_status_table
      .where(host_status_table[:type].eq('HostStatus::ConfigurationStatus')
        .and(is_relevant))
      .join(hosts_table)
        .on(host_status_table[:host_id].eq(hosts_table[:id])
          .and(hosts_table[:type].eq('Host::Managed')))
      .project(computed_status)
      .project(arel_quoted(1).count)
      .group('computed_status')
  end

  def owned_data_query
    host_status_table
      .where(host_status_table[:type].eq('HostStatus::ConfigurationStatus')
        .and(
          host_status_table[:host_id].in(
            Arel.sql(Host::Managed.search_for('owner = current_user').select(:id).to_sql)
          )
        )
        .and(is_relevant))
      .join(hosts_table).on(host_status_table[:host_id].eq(hosts_table[:id]).and(hosts_table[:type].eq('Host::Managed')))
      .project(computed_status)
      .project(arel_quoted(1).count)
      .group('computed_status')
  end

  def is_relevant
    hosts_table[:puppet_proxy_id].eq(nil).not
      .or(any_reports)
      .or(always_show_configuration_status)
  end

  def always_show_configuration_status
    settings_table
      .where(settings_table[:name].eq('always_show_configuration_status')
        .and(settings_table[:value].eq('--- true')
          .or(settings_table[:value].eq(nil).and(settings_table[:default].eq('--- true')))))
      .exists
  end

  # 0000 0000000000 0000000000 0000000000 0000000000 0000000000 0000000000
  # ----     [6]        [5]        [4]        [3]        [2]        [1]
  # [1] - applied
  # [2] - restarted
  # [3] - failed
  # [4] - failed_restarts
  # [5] - skipped
  # [6] - pending

  # WHEN pending THEN pending
  # WHEN failed OR failed_restarts THEN error
  # WHEN applied OR restarted THEN active
  # ELSE no_changes

  def computed_status
    arel_case
      .when(alerts_disabled).then(status_class::ALERTS_DISABLED)
      .when(no_reports).then(status_class::NO_REPORTS)
      .when(out_of_sync).then(status_class::OUT_OF_SYNC)
      .when(pending).then(status_class::PENDING)
      .when(failed_or_failed_restarts).then(status_class::ERROR)
      .when(applied_or_restarted).then(status_class::ACTIVE)
      .else(status_class::NO_CHANGES)
      .as('computed_status')
  end

  def alerts_disabled
    hosts_table[:enabled].eq(false)
  end

  def any_reports
    reports_table
      .where(reports_table[:type].eq('ConfigReport')
        .and(reports_table[:host_id].eq(host_status_table[:host_id])))
      .exists
  end

  def no_reports
    any_reports.not
  end

  def pending
    status = host_status_table[:status] & 0b1111111111_0000000000_0000000000_0000000000_0000000000_0000000000

    status.gteq(0b1_0000000000_0000000000_0000000000_0000000000_0000000000)
      .and(status.lteq(0b1111111111_0000000000_0000000000_0000000000_0000000000_0000000000))
  end

  def failed_or_failed_restarts
    status = host_status_table[:status] & 0b1111111111_1111111111_0000000000_0000000000

    status.gteq(0b1_0000000000_0000000000)
      .and(status.lteq(0b1111111111_1111111111_0000000000_0000000000))
  end

  def applied_or_restarted
    status = host_status_table[:status] & 0b1111111111_1111111111

    status.gteq(0b1)
      .and(status.lteq(0b1111111111_1111111111))
  end

  def out_of_sync
    out_of_sync_disabled.not
      .and(host_status_table[:id].in(out_of_sync_ids))
  end

  def out_of_sync_disabled
    settings_table
      .where(settings_table[:name].in(
        reports_table
          .where(reports_table[:type].eq('ConfigReport')
          .and(reports_table[:host_id].eq(host_status_table[:host_id])))
          .order(reports_table[:reported_at].desc)
          .take(1).project(
            arel_concat(reports_table[:origin].lower, arel_quoted('_out_of_sync_disabled'))
          ))
        .and(settings_table[:value].eq('--- true'))
        .or(settings_table[:value].eq(nil).and(settings_table[:default].eq('--- true'))))
      .exists
  end

  def out_of_sync_ids
    outofsync_interval_setting = settings_table.alias('outofsync_interval_setting')
    origin_interval_setting = settings_table.alias('origin_interval_setting')

    host_status_table
      .join(reports_table)
        .on(reports_table[:host_id].eq(host_status_table[:host_id])
        .and(reports_table[:id].eq(
          reports_table.where(reports_table[:host_id].eq(host_status_table[:host_id])).project(reports_table[:id].maximum)
        )))
      .join(outofsync_interval_setting)
        .on(outofsync_interval_setting[:name].eq('outofsync_interval'))
      .join(origin_interval_setting, arel_outer_join)
        .on(origin_interval_setting[:name].eq(arel_concat(reports_table[:origin], arel_quoted('_interval'))))
      .where(
        host_status_table[:reported_at].lteq(
          arel_subtraction(
            arel_now,
            expected_interval(
              interval_from_setting(outofsync_interval_setting),
              interval_from_setting(origin_interval_setting)
            )
          )
        )
      )
      .project(host_status_table[:id])
  end

  def expected_interval(outofsync_interval, origin_interval)
    arel_case
      .when(origin_interval.eq(nil))
      .then(arel_addition(outofsync_interval, outofsync_interval))
      .else(arel_addition(outofsync_interval, origin_interval))
  end

  def interval_from_setting(table)
    arel_case
      .when(table[:id].eq(nil).not)
      .then(
        arel_make_interval(
          0, 0, 0, 0, 0,
          arel_cast(
            arel_replace(
              arel_case.when(table[:value].eq(nil)).then(table[:default]).else(table[:value]),
              arel_quoted('--- '),
              arel_quoted('')
            ),
            'INTEGER'
          )
        )
      )
  end

  # Arel tables

  def host_status_table
    HostStatus::ConfigurationStatus.arel_table
  end

  def hosts_table
    Host::Managed.arel_table
  end

  def reports_table
    Report.arel_table
  end

  def settings_table
    Setting.arel_table
  end

  # Arel helpers

  def arel_quoted(quoted)
    Arel::Nodes.build_quoted(quoted)
  end

  def arel_cast(pred, type)
    Arel::Nodes::NamedFunction.new('cast', [pred.as(type)])
  end

  def arel_make_interval(*args)
    Arel::Nodes::NamedFunction.new('make_interval', args)
  end

  def arel_case(expression = nil)
    Arel::Nodes::Case.new(expression)
  end

  def arel_concat(*args)
    Arel::Nodes::NamedFunction.new('concat', args)
  end

  def arel_subtraction(left, right)
    Arel::Nodes::Subtraction.new(left, right)
  end

  def arel_addition(left, right)
    Arel::Nodes::Addition.new(left, right)
  end

  def arel_now
    Arel::Nodes::NamedFunction.new('now', [])
  end

  def arel_replace(*args)
    Arel::Nodes::NamedFunction.new('replace', args)
  end

  def arel_outer_join
    Arel::Nodes::OuterJoin
  end
end
