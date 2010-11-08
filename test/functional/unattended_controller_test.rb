require 'test_helper'

class UnattendedControllerTest < ActionController::TestCase
  test "should get a kickstart" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{hosts(:redhat).mac}"
    get :kickstart
    assert_response :success
  end

  test "should get a kickstart even if not using the first NIC" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "unused NIC"
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_3"] = "eth4 #{hosts(:redhat).mac}"
    get :kickstart
    assert_response :success
  end


  test "should get a preseed finish script" do
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    get :preseed_finish
    assert_response :success
  end

  test "should get a preseed" do
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    get :preseed
    assert_response :success
  end

  test "unattended files content type should be text/plain" do
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    get :preseed
    assert_response :success
    assert @response.headers["Content-Type"].match "text/plain"
  end

  test "should support spoof" do
    get :preseed, {:spoof => hosts(:ubuntu).ip}
    assert_response :success
  end

  test "should provide pxe config for redhat" do
    get :pxe_kickstart_config, {:host_id => hosts(:redhat).name}
    assert_response :success
  end

  test "should provide pxe config for debian" do
    get :pxe_debian_config, {:host_id => hosts(:ubuntu).name}
    assert_response :success
  end

  test "should accept built notifications" do
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    get :built
    assert_response :created
    host = Host.find_by_ip(hosts(:ubuntu).ip)
    assert_equal host.build,false
  end

  test "should not provide unattened files to hosts which are not in built state" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{hosts(:redhat).mac}"
    get :built
    assert_response :created
    get :kickstart
    assert_response :method_not_allowed
  end

  test "should not provide unattended files to hosts which we don't know about" do
    get :kickstart
    assert_response :not_found
  end

  test "should not provide unattended files to hosts which don't have an assign os" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{hosts(:two).mac}"
    get :kickstart
    assert_response :conflict
  end
end
