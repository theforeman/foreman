require 'test_helper'
class ReportStatusCalculatorTest < ActiveSupport::TestCase
  test 'it should not change host report status when we have skipped reports but there are no log entries' do
    r = ReportStatusCalculator.new(:counters => {'applied' => 0, 'restarted' => 0, 'failed' => 0, 'failed_restarts' => 0, 'skipped' => 1, 'pending' => 0})
    assert_equal 0, r.status['failed']
  end

  test 'it should save metrics as bits in status integer' do
    r = ReportStatusCalculator.new(:counters => {'applied' => 92, 'restarted' => 300, 'failed' => 4, 'failed_restarts' => 12, 'skipped' => 3, 'pending' => 4})
    assert_equal Report::MAX, r.status['applied']
    assert_equal Report::MAX, r.status['restarted']
    assert_equal 4, r.status['failed']
    assert_equal 12, r.status['failed_restarts']
    assert_equal 3, r.status['skipped']
    assert_equal 4, r.status['pending']
  end
end