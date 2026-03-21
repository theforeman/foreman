require 'test_helper'

class ProxyAPI::BMCTest < ActiveSupport::TestCase
  def setup
    @url = 'https://proxy.example.com:8443'
    @options = { url: @url, host_ip: '192.168.1.1', fqdn: 'bmc.example.com', bmc_provider: 'Redfish' }
    @bmc_api = ProxyAPI::BMC.new(@options)
  end

  test 'initialize should set target to host_ip if present' do
    assert_equal '192.168.1.1', @bmc_api.instance_variable_get(:@target)
  end

  test 'initialize should set target to fqdn if host_ip is not present' do
    options = { url: @url, fqdn: 'bmc.example.com' }
    bmc_api = ProxyAPI::BMC.new(options)
    assert_equal 'bmc.example.com', bmc_api.instance_variable_get(:@target)
  end

  test 'initialize should set target to 127.0.0.1 if fqdn and host_ip are not present' do
    options = { url: @url }
    bmc_api = ProxyAPI::BMC.new(options)
    assert_equal '127.0.0.1', bmc_api.instance_variable_get(:@target)
  end

  test 'power_on should call put with correct arguments' do
    @bmc_api.expects(:put).with({ bmc_provider: 'Redfish', action: 'on' }, '/192.168.1.1/chassis/power/on').returns('fake response').once
    @bmc_api.expects(:parse).with('fake response').returns({ 'result' => true })
    assert @bmc_api.power_on({})
  end

  test 'power_off should call put with correct arguments' do
    @bmc_api.expects(:put).with({ bmc_provider: 'Redfish', action: 'off' }, '/192.168.1.1/chassis/power/off').returns('fake response').once
    @bmc_api.expects(:parse).with('fake response').returns({ 'result' => true })
    assert @bmc_api.power_off({})
  end

  test 'power_status should call get with correct arguments' do
    expected_path = '/192.168.1.1/chassis/power/status'
    expected_query = { bmc_provider: 'Redfish' }
    @bmc_api.expects(:get).with(expected_path, query: expected_query).returns('fake response')
    @bmc_api.expects(:parse).with('fake response').returns({ 'result' => 'on' })
    assert_equal 'on', @bmc_api.power_status({})
  end

  test 'lan_ip should call get and return the result' do
    expected_path = '/192.168.1.1/lan/ip'
    expected_query = { bmc_provider: 'Redfish' }
    @bmc_api.expects(:get).with(expected_path, query: expected_query).returns('fake response')
    @bmc_api.expects(:parse).with('fake response').returns({ 'result' => '192.168.1.100' })
    assert_equal '192.168.1.100', @bmc_api.lan_ip({})
  end

  test 'boot_pxe should call boot with correct device' do
    args = { reboot: true }
    expected_args = { function: 'bootdevice', device: 'pxe', reboot: true, bmc_provider: 'Redfish' }
    @bmc_api.expects(:put).with(expected_args, '/192.168.1.1/chassis/config/bootdevice/pxe').returns('{}')
    @bmc_api.boot_pxe(args)
  end

  test 'method_missing should raise NoMethodError for invalid methods' do
    assert_raise(NoMethodError) { @bmc_api.invalid_method({}) }
  end

  test 'respond_to_missing? should be true for valid dynamic methods' do
    assert_respond_to @bmc_api, :power_on
    assert_respond_to @bmc_api, :boot_disk
    assert_respond_to @bmc_api, :identify_off
    assert_respond_to @bmc_api, :lan_mac
  end

  test 'respond_to_missing? should be false for invalid dynamic methods' do
    assert !@bmc_api.respond_to?(:invalid_method), "Should not respond to :invalid_method"
  end
end
