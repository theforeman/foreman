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

  test "should get a kickstart even if we are behind a loadbalancer" do
    @request.env["HTTP_X_FORWARDED_FOR"] = hosts(:redhat).ip
    @request.env["REMOTE_ADDR"] = "127.0.0.1"
    get :kickstart
    assert_response :success
  end

  test "should get a preseed finish script" do
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    get :preseed_finish
    assert_response :success
  end

  test "should get a preseed finish script with multiple ips in the request header" do
    @request.env["REMOTE_ADDR"] = [hosts(:ubuntu).ip, '1.2.3.4']
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
    assert @response.headers["Content-Type"].match("text/plain")
  end

  test "should support spoof" do
    get :preseed, {:spoof => hosts(:ubuntu).ip}, set_session_user
    assert_response :success
  end

  test "should render spoof when user is not logged in" do
    get :preseed, {:spoof => hosts(:ubuntu).ip}
    assert_response :redirect
  end

  test "should provide pxe config for redhat" do
    get :pxe_kickstart_config, {:spoof => hosts(:redhat).ip}, set_session_user
    assert_response :success
  end

  test "should provide pxe config for debian" do
    get :pxe_debian_config, {:spoof => hosts(:ubuntu).ip}, set_session_user
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
    setup_users

    hosts(:otherfullhost).update_attribute(:operatingsystem_id, nil)
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{hosts(:otherfullhost).mac}"
    get :kickstart
    assert_response :conflict
  end

  test "template with  hostgroup should be rendered" do
    get :template, {:id => "MyString", :hostgroup => "Common"}
    assert_response :success
  end

  test "template with non-existant  hostgroup should not be rendered" do
    get :template, {:id => "MyString2", :hostgroup => "NotArealHostgroup"}
    assert_response :not_found
  end

 test "requesting a template that does not exist should fail" do
    get :template, {:id => "kdsfjlkasjdfkl", :hostgroup => "Common"}
    assert_response :not_found
  end

  test "hosts with unknown ip and valid token should render a template" do
    Setting[:token_duration] = 30
    @request.env["REMOTE_ADDR"] = '127.0.0.1'
    hosts(:ubuntu).create_token(:value => "aaaaaa", :expires => Time.now + 5.minutes)
    get :preseed, {'token' => hosts(:ubuntu).token.value }
    assert_response :success
  end

  # Should this test be moved into renderer_test, as it excercises foreman_url() functionality?
  test "template should contain tokens when tokens enabled and present for the host" do
    Setting[:token_duration] = 30
    Setting[:foreman_url]    = "test.host"
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    hosts(:ubuntu).create_token(:value => "aaaaaa", :expires => Time.now + 5.minutes)
    get :preseed
    assert @response.body.include?("d-i preseed/late_command string wget http://test.host/unattended/finish?token=aaaaaa -O /target/tmp/finish.sh && in-target chmod +x /tmp/finish.sh && in-target /tmp/finish.sh")
  end

  # Should this test be moved into renderer_test, as it excercises foreman_url() functionality?
  test "template should not contain https when ssl enabled" do
    @request.env["HTTPS"] = "on"
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    get :preseed
    assert_no_match(/https/, @response.body)
  end

end
