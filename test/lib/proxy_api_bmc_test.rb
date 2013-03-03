require "test/unit"
require 'test_helper'
require "mocha/setup"

class ProxyApiBmcTest < ActiveSupport::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @url="http://localhost:8443"
    @options = {:username => "testuser", :password => "fakepass"}
    @testbmc = ProxyAPI::BMC.new({:user => "admin", :password => "secretpass", :url => @url})
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def fake_response(data)
    net_http_resp = Net::HTTPResponse.new(1.0, 200, "OK")
    net_http_resp.add_field 'Set-Cookie', 'Monster'
    RestClient::Response.create(JSON(data), net_http_resp, nil)
  end

  test "constructor should complete" do
    assert_not_nil(@testbmc)
  end

  test "base url should equal /bmc" do
    expected = @url+"/bmc"
    assert_equal(expected, @testbmc.url)
  end

  test "providers should get list of providers" do
    path = @url + "/bmc/providers"
    expected = ["freeipmi", "ipmitool"]
    @testbmc.stubs(:get).returns(fake_response(expected))
    assert_equal(expected, @testbmc.providers)
  end

  test "providers installed should get list of installed providers" do
    expected = ["freeipmi", "ipmitool"]
    path = @url + "/bmc/providers_installed"
    @testbmc.stubs(:get).returns(fake_response(expected))
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
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    assert_nothing_raised do
        @testbmc.boot_pxe(@options)
      end
  end

  test "boot function should create correct url for bootdevice pxe" do
    device = "pxe"
    expected_path = "/chassis/config/bootdevice/#{device}"
    data = @options.merge({:function => "bootdevice", :device => device})
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.boot_pxe(@options)

  end

  test "boot function should create correct url for bootdevice disk" do
    device = "disk"
    expected_path = "/chassis/config/bootdevice/#{device}"
    data = @options.merge({:function => "bootdevice", :device => device})
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.boot_disk(@options)
  end

  test "boot function should create correct url for bootdevice cdrom" do
    device = "cdrom"
    expected_path = "/chassis/config/bootdevice/#{device}"
    data = @options.merge({:function => "bootdevice", :device => device})
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.boot_cdrom(@options)

  end

  test "boot function should create correct url for bootdevice bios" do
    device = "bios"
    expected_path = "/chassis/config/bootdevice/#{device}"
    data = @options.merge({:function => "bootdevice", :device => device})
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.boot_bios(@options)
  end

  test "power function should create correct url for off" do
    action = "off"
    expected_path = "/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.power_off(@options)

  end

  test "power function should create correct url for on" do
    action = "on"
    expected_path = "/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.power_on(@options)
  end

  test "power function should create correct url for cycle" do
    action = "cycle"
    expected_path = "/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.power_cycle(@options)

  end

  test "power function should create correct url for soft" do
    action = "soft"
    expected_path = "/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.power_soft(@options)

  end

  test "power function should create correct url for off?" do
    action = "off"
    expected_path = "/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.power_off?(@options)

  end
  test "power function should create correct url for on?" do
    action = "on"
    expected_path = "/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.power_on?(@options)

  end

  test "power function should create correct url for status" do
    action = "status"
    expected_path = "/chassis/power/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.power_status(@options)

  end

  test "identify function should create correct url for off" do
    action = "off"
    expected_path = "/chassis/identify/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.identify_off(@options)

  end
  test "identify function should create correct url for on" do
    action = "on"
    expected_path = "/chassis/identify/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:put).returns(fake_response(["fakedata"]))
    @testbmc.expects(:put).with(data, expected_path).at_least_once
    @testbmc.identify_on(@options)

  end

  test "identify function should create correct url for status" do
    action = "status"
    expected_path = "/chassis/identify/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.identify_status(@options)

  end

  test "lan function should create correct url for ip" do
    action = "ip"
    expected_path = "/lan/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.lan_ip(@options)
  end

  test "lan function should create correct url for netmask" do
    action = "netmask"
    expected_path = "/lan/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.lan_netmask(@options)
  end

  test "lan function should create correct url for gateway" do
    action = "gateway"
    expected_path = "/lan/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.lan_gateway(@options)
  end

  test "lan function should create correct url for mac" do
    action = "mac"
    expected_path = "/lan/#{action}"
    data = @options.merge({:action => action})
    @testbmc.stubs(:get).returns(fake_response(["fakedata"]))
    @testbmc.expects(:get).with(expected_path, data).at_least_once
    @testbmc.lan_mac(@options)
  end




end