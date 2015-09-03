require 'test_helper'

class GlobalTest < ActiveSupport::TestCase
  class StatusMock < Struct.new(:global, :relevant)
    alias_method :relevant?, :relevant

    def to_global(options = {})
      global
    end
  end

  def setup
    @status1 = StatusMock.new(HostStatus::Global::WARN, true)
    @status2 = StatusMock.new(HostStatus::Global::ERROR, true)
    @status3 = StatusMock.new(HostStatus::Global::OK, true)
  end

  test '.build(statuses) builds new global status with highest status code' do
    global = HostStatus::Global.build([@status1, @status2, @status3])
    assert_equal HostStatus::Global::ERROR, global.status
  end

  test '.build(statuses, :last_reports => [reports]) uses reports cache for configuration statuses' do
    status = HostStatus::ConfigurationStatus.new
    report = Report.new(:host_id => 1)
    status.expects(:relevant?).returns(true)
    status.expects(:to_global).returns(:result)
    global = HostStatus::Global.build([ status ], :last_reports => [ report ])
    assert_equal :result, global.status
  end

  test '.to_label returns string representation of status code' do
    global = HostStatus::Global.new(HostStatus::Global::OK)
    assert_kind_of String, global.to_label
  end
end
