require 'test_helper'

class HostPowerInterfaceTest < ActiveSupport::TestCase
  test "#supports_power? should return true with compute resource" do
    host = FactoryBot.build_stubbed(:host, :on_compute_resource)
    host.unstub(:queue_compute)
    assert host.supports_power?
  end

  test "#supports_power? should return false without compute resource" do
    host = FactoryBot.build_stubbed(:host)
    refute host.supports_power?
  end

  test "#supports_power_and_running? should return true with compute resource and power ready" do
    power_mock = mock('power')
    power_mock.stubs(:ready?).returns(true)
    host = FactoryBot.build_stubbed(:host, :on_compute_resource)
    host.unstub(:queue_compute)
    host.stubs(:power).returns(power_mock)
    assert host.supports_power_and_running?
  end
end
