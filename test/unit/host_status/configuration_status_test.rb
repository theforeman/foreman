require 'test_helper'

class ConfigurationStatusTest < ActiveSupport::TestCase
  def setup
    @host = FactoryGirl.create(:host)
    @report = @host.reports.build
    @report.status = {"applied" => 92, "restarted" => 300, "failed" => 4, "failed_restarts" => 12, "skipped" => 3, "pending" => 0}
    @report.reported_at = '2015-01-01 00:00:00'
    @report.save
    @status = HostStatus::ConfigurationStatus.new(:host => @host)
    @status.refresh!
  end

  test '#last_report defaults to host\'s last if nothing was set yet' do
    assert_equal @report, @status.last_report
  end

  test '#last_report returns custom value that was set using writer method' do
    @status.last_report = :something
    assert_equal :something, @status.last_report
  end

  test '#last_report returns custom value that was set using writer method even for nil' do
    @status.last_report = nil
    assert_nil @status.last_report
  end

  test '#out_of_sync? is false if host reporting is disabled' do
    assert @status.out_of_sync?

    @host.enabled = false
    refute @status.out_of_sync?
  end

  test '#out_of_sync? is true if reported_at is set and is too long ago' do
    assert @status.reported_at.present?
    window = (Setting[:puppet_interval] + Setting[:outofsync_interval]).minutes
    assert @status.reported_at < Time.now - window

    assert @status.out_of_sync?
  end

  test '#out_of_sync? is false when reported_at is unknown' do
    @status.reported_at = nil
    refute @status.out_of_sync?
  end

  test '#out_of_sync? is false when window is big enough' do
    original, Setting[:outofsync_interval] = Setting[:outofsync_interval], (Time.now - @report.reported_at).to_i / 60 + 1
    refute @status.out_of_sync?
    Setting[:outofsync_interval] = original
  end

  test '#refresh! refreshes the date and persists the record' do
    @status.expects(:refresh)
    @status.refresh!

    assert @status.persisted?
  end

  test '#refresh updates date to reported_at of last report' do
    @status.reported_at = nil
    @status.refresh

    assert_equal @report.reported_at, @status.reported_at
  end

  test '.is_not' do
    assert_equal '((host_status.status >> 6 & 63) = 0)', HostStatus::ConfigurationStatus.is_not('restarted')
  end

  test '.is' do
    assert_equal '((host_status.status >> 6 & 63) != 0)', HostStatus::ConfigurationStatus.is('restarted')
  end

  test '.bit_mask' do
    assert_equal '0 & 63', HostStatus::ConfigurationStatus.bit_mask('applied')
    assert_equal '6 & 63', HostStatus::ConfigurationStatus.bit_mask('restarted')
    assert_equal '12 & 63', HostStatus::ConfigurationStatus.bit_mask('failed')
  end
end
