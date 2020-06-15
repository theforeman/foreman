require 'test_helper'

class ReportedDataFacetTest < ActiveSupport::TestCase
  describe '#uptime_seconds' do
    test 'should return uptime in seconds' do
      host = FactoryBot.create(:host)
      freeze_time do
        boot_time = 1.day.ago
        host.create_reported_data(:boot_time => boot_time)
        now = Time.zone.now.to_i
        assert_equal host.uptime_seconds, now - boot_time.to_i
      end
    end

    test 'should return nil if no uptime fact is available' do
      host = FactoryBot.create(:host)
      assert_nil host.uptime_seconds
    end

    test 'should not fail on host without reported data' do
      host = FactoryBot.create(:host)
      assert_nothing_raised do
        host.clear_data_on_build
      end
    end

    test 'should delete reported data on rebuild' do
      host = FactoryBot.create(:host)
      boot_time = 1.day.ago
      host.create_reported_data(:boot_time => boot_time)
      refute_nil host.uptime_seconds
      host.instance_variable_set '@old', host.clone
      host.build = true
      host.clear_data_on_build
      host.reload
      assert_nil host.uptime_seconds
    end

    test 'should return nil if no uptime fact is available' do
      host = FactoryBot.create(:host)
      assert_nil host.uptime_seconds
    end
  end

  describe '#boot_time=' do
    test 'should process boot_time assignmet in seconds' do
      host = FactoryBot.create(:host)
      freeze_time do
        boot_time = 1.day.ago.to_i
        host.create_reported_data(:boot_time => boot_time)
        assert_equal host.uptime_seconds, Time.zone.now.to_i - boot_time
      end
    end
  end
end
