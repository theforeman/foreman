require 'test_helper'

class ProxyApiWolTest < ActiveSupport::TestCase
  def setup
    @url = "http://dummyproxy.theforeman.org:8443"
    @wol_proxy = ProxyAPI::Wol.new({:url => @url})
  end

  test "base url should equal /wol" do
    expected = @url + "/wol"
    assert_equal(expected, @wol_proxy.url)
  end

  test "wake should raise exception when MAC address is nil" do
    exception = assert_raise ProxyAPI::ProxyException do
      @wol_proxy.wake(nil)
    end
    assert_includes(exception.message, "Must define a MAC address")
  end

  test "wake should handle proxy communication errors" do
    mac = "00:11:22:33:44:55"
    error = StandardError.new("Connection timeout")

    @wol_proxy.stubs(:post).raises(error)

    exception = assert_raise ProxyAPI::ProxyException do
      @wol_proxy.wake(mac)
    end

    assert_match(/Unable to send Wake on LAN request for MAC/, exception.message)
    assert_match(/#{mac}/, exception.message)
  end

  test "wake should handle JSON parsing errors" do
    mac = "00:11:22:33:44:55"
    expected_params = { :mac_address => mac }

    @wol_proxy.stubs(:post).with(expected_params).returns(fake_rest_client_response("invalid json"))
    @wol_proxy.stubs(:parse).raises(JSON::ParserError.new("Invalid JSON"))

    exception = assert_raise ProxyAPI::ProxyException do
      @wol_proxy.wake(mac)
    end

    assert_match(/Unable to send Wake on LAN request for MAC/, exception.message)
    assert_match(/#{mac}/, exception.message)
  end

  test "wake should return parsed response on success" do
    mac = "00:11:22:33:44:55"
    expected_params = { :mac_address => mac }
    response_data = { "status" => "success", "result" => true }

    @wol_proxy.stubs(:post).with(expected_params).returns(fake_rest_client_response(response_data))
    @wol_proxy.stubs(:parse).returns(response_data)

    result = @wol_proxy.wake(mac)
    assert_equal(response_data, result)
  end

  private

  def fake_rest_client_response(data)
    response = mock('RestClient::Response')
    response.stubs(:body).returns(data.to_json)
    response
  end
end
