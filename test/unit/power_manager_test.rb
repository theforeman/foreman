require 'test_helper'

class PowerManagerTest < ActiveSupport::TestCase
  test "should respond to all supported actions with compute resource" do
    vm_mock = mock('vm')

    compute_resource_mock = mock('compute_resource')
    compute_resource_mock.stubs(:find_vm_by_uuid).returns(vm_mock)

    host = FactoryGirl.build(:host, :on_compute_resource)
    host.unstub(:queue_compute)
    host.stubs(:compute_resource).returns(compute_resource_mock)

    host.power.send(:action_map).values.uniq.each do |action|
      vm_mock.expects(action.to_sym).at_least_once.returns(true)
    end
    vm_mock.stubs(:reload).returns(true)

    PowerManager::SUPPORTED_ACTIONS.each do |action|
      assert host.power.send(action.to_sym), "Failed to send #{action} to host power manager"
    end
  end

  test "should respond to all supported actions with bmc" do
    host = FactoryGirl.build(:host, :managed)
    bmc_proxy_mock = mock('bmc_proxy')
    host.stubs(:bmc_proxy).returns(bmc_proxy_mock)
    host.stubs(:bmc_available?).returns(true)

    (host.power.send(:action_map).values.uniq - ['status']).each do |action|
      bmc_proxy_mock.expects(:power).with(:action => action).at_least_once.returns(true)
    end
    bmc_proxy_mock.expects(:power).with(:action => 'status').at_least_once.returns('on')

    PowerManager::SUPPORTED_ACTIONS.each do |action|
      assert host.power.send(action.to_sym), "Failed to send #{action} to host power manager"
    end
  end

  test "real actions should be in supported actions" do
    PowerManager::REAL_ACTIONS.each do |action|
      assert_includes PowerManager::SUPPORTED_ACTIONS, action
    end
  end
end
