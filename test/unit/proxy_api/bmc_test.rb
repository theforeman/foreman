require 'test_helper'
require "mocha/setup"

class ProxyApiBmcTest < ActiveSupport::TestCase
  def setup
    @url = "http://dummyproxy.theforeman.org:8443"
    @options = {:username => "testuser", :password => "fakepass"}
    @testbmc = ProxyAPI::BMC.new({:user => "admin", :password => "secretpass", :url => @url})
  end

  test "constructor should complete" do
    assert_not_nil(@testbmc)
  end

  test "base url should equal /bmc" do
    expected = @url + "/bmc"
    assert_equal(expected, @testbmc.url)
  end

  test "providers should get list of providers" do
    expected = ["freeipmi", "ipmitool"]
    @testbmc.stubs(:get).returns(fake_rest_client_response(expected))
    assert_equal(expected, @testbmc.providers)
  end

  test "providers installed should get list of installed providers" do
    expected = ["freeipmi", "ipmitool"]
    @testbmc.stubs(:get).returns(fake_rest_client_response(expected))
    assert_equal(expected, @testbmc.providers_installed)
  end

  test "boot function should raise nomethod exception when function does not exist" do
    assert_raise NoMethodError do
      @testbmc.boot_fake(@options)
    end
  end

  test "power function should raise nomethod exception when function does not exist" do
    assert_raise NoMethodError do
      @testbmc.power_fake(@options)
    end
  end

  test "identify function should raise nomethod exception when function does not exist" do
    assert_raise NoMethodError do
      @testbmc.identify_fake(@options)
    end
  end

  test "lan function should raise nomethod exception when function does not exist" do
    assert_raise NoMethodError do
      @testbmc.lan_fake(@options)
    end
  end

  test "boot function should not raise nomethod exception when function does exist" do
    @testbmc.stubs(:put).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.boot_pxe(@options)
  end

  test "boot function should create correct url for bootdevice pxe" do
    device = "pxe"
    expected_path = "/127.0.0.1/chassis/config/bootdevice/#{device}"
    data = @options.merge({:function => "bootdevice", :device => device})
    @testbmc.stubs(:put).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.boot_pxe(@options)
  end

  test "boot function should create correct url for bootdevice disk" do
    device = "disk"
    expected_path = "/127.0.0.1/chassis/config/bootdevice/#{device}"
    data = @options.merge({:function => "bootdevice", :device => device})
    @testbmc.stubs(:put).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.boot_disk(@options)
  end

  test "boot function should create correct url for bootdevice cdrom" do
    device = "cdrom"
    expected_path = "/127.0.0.1/chassis/config/bootdevice/#{device}"
    data = @options.merge({:function => "bootdevice", :device => device})
    @testbmc.stubs(:put).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.boot_cdrom(@options)
  end

  test "boot function should create correct url for bootdevice bios" do
    device = "bios"
    expected_path = "/127.0.0.1/chassis/config/bootdevice/#{device}"
    data = @options.merge({:function => "bootdevice", :device => device})
    @testbmc.stubs(:put).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.boot_bios(@options)
  end

  test "power function should create correct url for off" do
    action = "off"
    expected_path = "/127.0.0.1/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.power_off(@options)
  end

  test "power function should create correct url for on" do
    action = "on"
    expected_path = "/127.0.0.1/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.power_on(@options)
  end

  test "power function should create correct url for cycle" do
    action = "cycle"
    expected_path = "/127.0.0.1/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.power_cycle(@options)
  end

  test "power function should create correct url for soft" do
    action = "soft"
    expected_path = "/127.0.0.1/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_rest_client_response({"result" => true}))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.power_soft(@options)
  end

  test "power function should create correct url for off?" do
    action = "off"
    expected_path = "/127.0.0.1/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.power_off?(@options)
  end
  test "power function should create correct url for on?" do
    action = "on"
    expected_path = "/127.0.0.1/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.power_on?(@options)
  end

  test "power function should create correct url for status" do
    action = "status"
    expected_path = "/127.0.0.1/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.power_status(@options)
  end

  test "identify function should create correct url for off" do
    action = "off"
    expected_path = "/127.0.0.1/chassis/identify/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.identify_off(@options)
  end
  test "identify function should create correct url for on" do
    action = "on"
    expected_path = "/127.0.0.1/chassis/identify/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.identify_on(@options)
  end

  test "identify function should create correct url for status" do
    action = "status"
    expected_path = "/127.0.0.1/chassis/identify/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.identify_status(@options)
  end

  test "lan function should create correct url for ip" do
    action = "ip"
    expected_path = "/127.0.0.1/lan/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.lan_ip(@options)
  end

  test "lan function should create correct url for netmask" do
    action = "netmask"
    expected_path = "/127.0.0.1/lan/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.lan_netmask(@options)
  end

  test "lan function should create correct url for gateway" do
    action = "gateway"
    expected_path = "/127.0.0.1/lan/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.lan_gateway(@options)
  end

  test "lan function should create correct url for mac" do
    action = "mac"
    expected_path = "/127.0.0.1/lan/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_rest_client_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.lan_mac(@options)
  end

  context '#power' do
    test "should return true when result was true" do
      data = stub_bmc_power_response('cycle', true)
      assert_equal true, @testbmc.power(data)
    end

    test "should return true when result was ok" do
      data = stub_bmc_power_response('cycle', "127.0.0.1: ok\n")
      assert_equal true, @testbmc.power(data)
    end

    test "should return false when result was not ok" do
      data = stub_bmc_power_response('cycle', 'error')
      assert_equal false, @testbmc.power(data)
    end
  end

  private

  def stub_bmc_power_response(action, result)
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(
      fake_rest_client_response(
        {
          'action' => action,
          'result' => result,
        }
      )
    )
    data
  end
end
