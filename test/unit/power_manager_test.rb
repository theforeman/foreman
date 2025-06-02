require 'test_helper'

class PowerManagerTest < ActiveSupport::TestCase
  test "should respond to all supported actions with compute resource" do
    vm_mock = mock('vm')

    compute_resource_mock = mock('compute_resource')
    compute_resource_mock.stubs(:find_vm_by_uuid).returns(vm_mock)

    host = FactoryBot.build_stubbed(:host, :on_compute_resource)
    host.unstub(:queue_compute)
    host.stubs(:compute_resource).returns(compute_resource_mock)

    (actions_list(host) - ['virt_state']).each do |action|
      vm_mock.expects(action.to_sym).at_least_once.returns(true)
    end
    vm_mock.expects('state').at_least_once.returns('On')
    vm_mock.stubs(:reload).returns(true)

    PowerManager::SUPPORTED_ACTIONS.each do |action|
      assert host.power.send(action.to_sym), "Failed to send #{action} to host power manager"
    end
  end

  test "should respond to all supported actions with bmc" do
    host = FactoryBot.build_stubbed(:host, :managed)
    bmc_proxy_mock = mock('bmc_proxy')
    host.stubs(:bmc_proxy).returns(bmc_proxy_mock)
    host.stubs(:bmc_available?).returns(true)

    (actions_list(host) - ['status', 'ready?']).each do |action|
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

  context '#status' do
    setup do
      @vm_mock = mock('vm')

      compute_resource_mock = mock('compute_resource')
      compute_resource_mock.stubs(:find_vm_by_uuid).returns(@vm_mock)

      @host = FactoryBot.build_stubbed(:host, :on_compute_resource)
      @host.unstub(:queue_compute)
      @host.stubs(:compute_resource).returns(compute_resource_mock)
      @vm_mock.stubs(:reload).returns(true)
    end

    test "should respond correctly to status when compute resource is started" do
      @vm_mock.expects(:state).at_least_once.returns('Started')
      result = @host.power.status
      assert_equal 'on', result
    end

    test "should respond correctly to status when compute resource is paused" do
      @vm_mock.expects(:state).at_least_once.returns('Paused')
      result = @host.power.state
      assert_equal 'off', result
    end
  end

  def actions_list(host)
    action_map = host.power.send(:action_map)
    actions = PowerManager::SUPPORTED_ACTIONS - action_map.keys.map { |k| k.to_s }
    action_map.each do |key, value|
      action_entry = value
      action_entry = {:action => value.to_sym} unless value.is_a?(Hash)
      action = action_entry[:action]

      actions << action.to_s if action
    end
    actions.uniq
  end

  test "should call reboot and reset directly when power_action_v2 is supported" do
    host = FactoryBot.build_stubbed(:host, :managed)
    bmc_proxy_mock = mock('bmc_proxy')
    nic_mock = mock('nic_bmc')
    relation_mock = mock('smart_proxies_relation')
    bmc_caps = mock('bmc_caps')
    filtered_relation_mock = mock('filtered_relation_mock')

    host.stubs(:bmc_proxy).returns(bmc_proxy_mock)
    host.stubs(:bmc_nic).returns(nic_mock)
    nic_mock.stubs(:credentials_present?).returns(true)
    nic_mock.stubs(:provider).returns('IPMI')
    host.stubs(:bmc_available?).returns(true)
    host.stubs(:smart_proxies).returns(relation_mock)
    relation_mock.stubs(:with_features).with(:BMC).returns(filtered_relation_mock)
    filtered_relation_mock.stubs(:first).returns(bmc_caps)
    bmc_caps.stubs(:has_capability?).with(:BMC, :power_action_v2).returns(true)

    bmc_proxy_mock.expects(:power).with(:action => "reboot").returns(true)
    bmc_proxy_mock.expects(:power).with(:action => "reset").returns(true)

    assert host.power.reboot
    assert host.power.reset
  end

  test "should fallback to soft and cycle when power_action_v2 is not supported" do
    host = FactoryBot.build_stubbed(:host, :managed)
    bmc_proxy_mock = mock('bmc_proxy')
    nic_mock = mock('nic_bmc')
    relation_mock = mock('smart_proxies_relation')
    bmc_caps = mock('bmc_caps')
    filtered_relation_mock = mock('filtered_relation_mock')

    host.stubs(:bmc_proxy).returns(bmc_proxy_mock)
    host.stubs(:bmc_nic).returns(nic_mock)
    nic_mock.stubs(:credentials_present?).returns(true)
    nic_mock.stubs(:provider).returns('IPMI')
    host.stubs(:bmc_available?).returns(true)
    host.stubs(:smart_proxies).returns(relation_mock)
    relation_mock.stubs(:with_features).with(:BMC).returns(filtered_relation_mock)
    filtered_relation_mock.stubs(:first).returns(bmc_caps)
    bmc_caps.stubs(:has_capability?).with(:BMC, :power_action_v2).returns(false)

    bmc_proxy_mock.expects(:power).with(:action => "soft").returns(true)
    bmc_proxy_mock.expects(:power).with(:action => "cycle").returns(true)

    assert host.power.reboot
    assert host.power.reset
  end
end
