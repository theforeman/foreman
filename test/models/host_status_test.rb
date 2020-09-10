require 'test_helper'

class HostStatusTest < ActiveSupport::TestCase
  class DummyStatus < HostStatus::Status
    def self.status_name
      N_("DummyStatus")
    end
  end

  test '.status_registry allows adding new status and recalling it later' do
    status = OpenStruct
    HostStatus.status_registry.add(status)
    assert_includes HostStatus.status_registry, status
    HostStatus.status_registry.delete(status)
    refute_includes HostStatus.status_registry, status
  end

  test '.find_status_by_humanized_name' do
    assert_equal HostStatus::ConfigurationStatus, HostStatus.find_status_by_humanized_name('configuration')

    HostStatus.status_registry.add(DummyStatus)
    assert_equal DummyStatus, HostStatus.find_status_by_humanized_name('dummy_status')
    HostStatus.status_registry.delete(DummyStatus)
    refute_includes HostStatus.status_registry, DummyStatus
  end
end
