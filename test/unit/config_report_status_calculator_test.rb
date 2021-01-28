require 'test_helper'
class ConfigReportStatusCalculatorTest < ActiveSupport::TestCase
  test 'it should return status' do
    r = ConfigReportStatusCalculator.new(:counters => {'applied' => 0, 'restarted' => 0, 'failed' => 0, 'failed_restarts' => 0, 'skipped' => 1, 'pending' => 0})
    expected = {"applied" => 0, "restarted" => 0, "failed" => 0, "failed_restarts" => 0, "skipped" => 1, "pending" => 0}
    assert_equal expected, r.status
  end

  test 'it should not change host report status when we have skipped reports but there are no log entries' do
    r = ConfigReportStatusCalculator.new(:counters => {'applied' => 0, 'restarted' => 0, 'failed' => 0, 'failed_restarts' => 0, 'skipped' => 1, 'pending' => 0})
    assert_equal 0, r.status['failed']
  end

  test 'it should save metrics as bits in status integers' do
    r = ConfigReportStatusCalculator.new(:size => 6, :counters => {
                                           'applied': 1,
      'restarted': 2,
      'failed': 3,
      'failed_restarts': 4,
      'skipped': 5,
      'pending': 6,
                                         })
    assert_equal 1, r.status_of('applied')
    assert_equal 2, r.status_of('restarted')
    assert_equal 3, r.status_of('failed')
    assert_equal 4, r.status_of('failed_restarts')
    assert_equal 5, r.status_of('skipped')
    assert_equal 6, r.status_of('pending')
  end

  test 'it should save metrics as bits in status strings' do
    r = ConfigReportStatusCalculator.new(:size => 6, :counters => {
                                           'applied': 0,
      'restarted': 1,
      'failed': 63,
      'failed_restarts': 64,
      'skipped': 100,
      'pending': 200,
                                         })
    assert_equal "0", r.status_as_text_of('applied')
    assert_equal "1", r.status_as_text_of('restarted')
    assert_equal "63+", r.status_as_text_of('failed')
    assert_equal "63+", r.status_as_text_of('failed_restarts')
    assert_equal "63+", r.status_as_text_of('skipped')
    assert_equal "63+", r.status_as_text_of('pending')
  end

  test 'it should make use of some bits for (the legacy) word size 6' do
    maximum_value = 63
    r = ConfigReportStatusCalculator.new(:size => 6, :counters => {
                                           'applied': maximum_value,
      'restarted': maximum_value,
      'failed': maximum_value,
      'failed_restarts': maximum_value,
      'skipped': maximum_value,
      'pending': maximum_value,
                                         })
    assert_equal 0xFFFFFFFFF, r.calculate, "Expected in hex: %x, Actual in hex: %x" % [0xFFFFFFFFF, r.calculate]
  end

  test 'it should make use of all bits available' do
    maximum_value = 255
    r = ConfigReportStatusCalculator.new(:metrics => %w[1 2 3 4 5 6 7 8], :counters => {
                                           '1': maximum_value,
      '2': maximum_value,
      '3': maximum_value,
      '4': maximum_value,
      '5': maximum_value,
      '6': maximum_value,
      '7': maximum_value,
      '8': maximum_value,
                                         })
    assert_equal 0xFFFFFFFFFFFFFFFF, r.calculate, "Expected in hex: %x, Actual in hex: %x" % [0xFFFFFFFFFFFFFFFF, r.calculate]
  end

  test 'it should make use of 60 bits for Puppet' do
    maximum_value = 1023
    r = ConfigReportStatusCalculator.new(:metrics => %w[applied restarted failed failed_restarts skipped pending],
      :counters => {
        'applied': maximum_value,
        'restarted': maximum_value,
        'failed': maximum_value,
        'failed_restarts': maximum_value,
        'skipped': maximum_value,
        'pending': maximum_value,
      })
    # the most significant short is unused (10bit * 6 metrics = 60bits)
    assert_equal 0x0FFFFFFFFFFFFFFF, r.calculate, "Expected in hex: %x, Actual in hex: %x" % [0x0FFFFFFFFFFFFFFF, r.calculate]
  end
end
