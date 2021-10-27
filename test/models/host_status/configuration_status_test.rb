require 'test_helper'

class ConfigurationStatusTest < ActiveSupport::TestCase
  def setup
    @host = FactoryBot.create(:host)
    @report = @host.reports.build
    @report.status = {"applied" => 92, "restarted" => 300, "failed" => 4, "failed_restarts" => 12, "skipped" => 3, "pending" => 0}
    @report.reported_at = '2015-01-01 00:00:00'
    @report.save
    @status = HostStatus::ConfigurationStatus.new(:host => @host)
  end

  test 'is valid' do
    assert_valid @status
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

  test '#no_reports? results in warning only if puppet reports are expected' do
    @status.stubs(:error? => false)
    @status.stubs(:out_of_sync? => false)
    @status.stubs(:no_reports? => true)
    assert_equal HostStatus::Global::OK, @status.to_global

    @host.expects(:configuration? => true)
    assert_equal HostStatus::Global::WARN, @status.to_global

    @host.expects(:configuration? => false)
    Setting[:always_show_configuration_status] = true
    assert_equal HostStatus::Global::WARN, @status.to_global
  end

  test '#out_of_sync? is false if host reporting is disabled' do
    @status.refresh!
    assert @status.out_of_sync?

    @host.enabled = false
    refute @status.out_of_sync?
  end

  test '#out_of_sync? is true if reported_at is set and is too long ago' do
    @status.refresh!
    assert @status.reported_at.present?
    window = Setting[:outofsync_interval].minutes
    assert @status.reported_at < Time.now.utc - window

    assert @status.out_of_sync?
  end

  test '#out_of_sync? is false when reported_at is unknown' do
    @status.reported_at = nil
    refute @status.out_of_sync?
  end

  test '#out_of_sync? is false when window is big enough' do
    original, Setting[:outofsync_interval] = Setting[:outofsync_interval], (Time.now.utc - @report.reported_at).to_i / 60 + 1
    refute @status.out_of_sync?
    Setting[:outofsync_interval] = original
  end

  describe '#out_of_sync?' do
    let(:host) { FactoryBot.create(:host, :with_reports) }
    let(:status) do
      HostStatus::ConfigurationStatus.new(:host => host)
    end

    test '#out_of_sync? is false when out of sync is disabled' do
      status.stubs(:out_of_sync_disabled?).returns(true)
      refute @status.out_of_sync?
    end

    context 'with last report origin' do
      setup do
        status.last_report.stubs(:origin).returns('TestOrigin')
      end

      test 'is false when origins out of sync is disabled' do
        stub_outofsync_setting(true)
        refute status.out_of_sync?
      end

      test "is true when origins out of sync isn't disbled and it is ouf of sync" do
        stub_outofsync_setting(false)
        status.reported_at = '2015-01-01 00:00:00'
        status.save
        assert status.out_of_sync?
      end

      def stub_outofsync_setting(value)
        Foreman.settings._add('testorigin_out_of_sync_disabled',
          context: :test,
          type: :boolean,
          category: 'Setting',
          full_name: 'Test out of sync',
          description: 'description',
          default: false)
        Setting[:testorigin_out_of_sync_disabled] = value
      end
    end
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

  test '#relevant? only for hosts with #configuration? true, or a last report, or setting enabled' do
    @host.expects(:configuration?).returns(true)
    assert @status.relevant?

    @host.expects(:configuration?).returns(false)
    @status.expects(:last_report).returns(mock)
    assert @status.relevant?

    @host.expects(:configuration?).returns(false)
    @status.expects(:last_report).returns(nil)
    refute @status.relevant?

    @host.expects(:configuration?).returns(false)
    @status.expects(:last_report).returns(nil)
    Setting[:always_show_configuration_status] = true
    assert @status.relevant?
  end

  test '.is_not' do
    assert_equal '((host_status.status >> 10 & 1023) = 0)', HostStatus::ConfigurationStatus.is_not('restarted')
  end

  test '.is' do
    assert_equal '((host_status.status >> 10 & 1023) != 0)', HostStatus::ConfigurationStatus.is('restarted')
  end

  test '.bit_mask' do
    assert_equal '0 & 1023', HostStatus::ConfigurationStatus.bit_mask('applied')
    assert_equal '10 & 1023', HostStatus::ConfigurationStatus.bit_mask('restarted')
    assert_equal '20 & 1023', HostStatus::ConfigurationStatus.bit_mask('failed')
  end

  test 'host search by status works' do
    @status.save
    assert_equal [@host], Host.search_for('status.applied = 0')
    assert_equal [@host], Host.search_for('status.applied = false')
    assert_equal [], Host.search_for('status.applied = 1')
  end

  test 'overwrite outofsync_interval as host parameter' do
    window = 30
    Setting['outofsync_interval'] = 10
    @status.reported_at = Time.now.utc - window.minutes
    assert @status.out_of_sync?
    # should be not out of sync if Setting['outofsync_interval'] is overwritten by parameter
    @host.params['outofsync_interval'] = 25
    refute @status.out_of_sync?
  end
end
