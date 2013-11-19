require 'test_helper'

class UnattendedControllerTest < ActionController::TestCase
  setup do
    System::Managed.any_instance.stubs(:handle_ca).returns(true)
  end

  test "should get a kickstart" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{systems(:redhat).mac}"
    get :kickstart
    assert_response :success
  end

  test "should get a kickstart even if not using the first NIC" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "unused NIC"
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_3"] = "eth4 #{systems(:redhat).mac}"
    get :kickstart
    assert_response :success
  end

  test "should get a kickstart even if we are behind a loadbalancer" do
    @request.env["HTTP_X_FORWARDED_FOR"] = systems(:redhat).ip
    @request.env["REMOTE_ADDR"] = "127.0.0.1"
    get :kickstart
    assert_response :success
  end

  test "should get a preseed finish script" do
    @request.env["REMOTE_ADDR"] = systems(:ubuntu).ip
    get :preseed_finish
    assert_response :success
  end

  test "should get a preseed finish script with multiple ips in the request header" do
    @request.env["REMOTE_ADDR"] = [systems(:ubuntu).ip, '1.2.3.4']
    get :preseed_finish
    assert_response :success
  end

  test "should get a preseed" do
    @request.env["REMOTE_ADDR"] = systems(:ubuntu).ip
    get :preseed
    assert_response :success
  end

  test "unattended files content type should be text/plain" do
    @request.env["REMOTE_ADDR"] = systems(:ubuntu).ip
    get :preseed
    assert_response :success
    assert @response.headers["Content-Type"].match("text/plain")
  end

  test "should support spoof" do
    get :preseed, {:spoof => systems(:ubuntu).ip}, set_session_user
    assert_response :success
  end

  test "should render spoof when user is not logged in" do
    get :preseed, {:spoof => systems(:ubuntu).ip}
    assert_response :redirect
  end

  test "should provide pxe config for redhat" do
    get :pxe_kickstart_config, {:spoof => systems(:redhat).ip}, set_session_user
    assert_response :success
  end

  test "should provide pxe config for debian" do
    get :pxe_debian_config, {:spoof => systems(:ubuntu).ip}, set_session_user
    assert_response :success
  end

  test "should render spoof pxelinux for a system" do
    get :PXELinux, {:spoof => systems(:myfullsystem).ip}, set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
    assert_response :success
  end

  test "should render spoof pxegrub for a system" do
    get :PXEGrub, {:spoof => systems(:myfullsystem).ip}, set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
    assert_response :success
  end

  test "should render spoof gpxe for a system" do
    get :gPXE, {:spoof => systems(:myfullsystem).ip}, set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
    assert_response :success
  end

  test "should accept built notifications" do
    @request.env["REMOTE_ADDR"] = systems(:ubuntu).ip
    get :built
    assert_response :created
    system = System.find_by_ip(systems(:ubuntu).ip)
    assert_equal system.build,false
  end

  test "should not provide unattened files to systems which are not in built state" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{systems(:redhat).mac}"
    get :built
    assert_response :created
    get :kickstart
    assert_response :method_not_allowed
  end

  test "should not provide unattended files to systems which we don't know about" do
    get :kickstart
    assert_response :not_found
  end

  test "should not provide unattended files to systems which don't have an assign os" do
    setup_users

    systems(:otherfullsystem).update_attribute(:operatingsystem_id, nil)
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{systems(:otherfullsystem).mac}"
    get :kickstart
    assert_response :conflict
  end

  test "template with  system_group should be rendered" do
    get :template, {:id => "MyString", :system_group => "Common"}
    assert_response :success
  end

  test "template with non-existant  system_group should not be rendered" do
    get :template, {:id => "MyString2", :system_group => "NotArealSystemGroup"}
    assert_response :not_found
  end

 test "requesting a template that does not exist should fail" do
    get :template, {:id => "kdsfjlkasjdfkl", :system_group => "Common"}
    assert_response :not_found
  end

  test "systems with unknown ip and valid token should render a template" do
    Setting[:token_duration] = 30
    @request.env["REMOTE_ADDR"] = '127.0.0.1'
    systems(:ubuntu).create_token(:value => "aaaaaa", :expires => Time.now + 5.minutes)
    get :preseed, {'token' => systems(:ubuntu).token.value }
    assert_response :success
  end

  test "systems with mismatched ip and update_ip=false should have the old ip" do
    disable_orchestration # avoids dns errors
    Setting[:token_duration] = 30
    Setting[:update_ip_from_built_request] = false
    @request.env["REMOTE_ADDR"] = '127.0.0.1'
    h=systems(:ubuntu2)
    h.create_token(:value => "aaaaaa", :expires => Time.now + 5.minutes)
    get :built, {'token' => h.token.value }
    h_new=System.find_by_name(h.name)
    assert_response :success
    assert_equal h.ip, h_new.ip
  end

  test "systems with mismatched ip and update_ip true should have the new ip" do
    disable_orchestration # avoids dns errors
    Setting[:token_duration] = 30
    Setting[:update_ip_from_built_request] = true
    @request.env["REMOTE_ADDR"] = '2.3.4.199'
    h=systems(:ubuntu2)
    assert_equal '2.3.4.106', h.ip
    h.create_token(:value => "aaaaab", :expires => Time.now + 5.minutes)
    get :built, {'token' => h.token.value }
    h_new=System.find_by_name(h.name)
    assert_response :success
    assert_equal '2.3.4.199', h_new.ip
  end

  test "systems with mismatched ip and update_ip true and a duplicate ip should succeed with no ip update" do
    disable_orchestration # avoids dns errors
    Setting[:token_duration] = 30
    Setting[:update_ip_from_built_request] = true
    @request.env["REMOTE_ADDR"] = systems(:redhat).ip
    h=systems(:ubuntu2)
    h.create_token(:value => "aaaaac", :expires => Time.now + 5.minutes)
    get :built, {'token' => h.token.value }
    assert_response :success
    h_new=System.find_by_name(h.name)
    assert_equal h.ip, h_new.ip
  end

  # Should this test be moved into renderer_test, as it excercises foreman_url() functionality?
  test "template should contain tokens when tokens enabled and present for the system" do
    Setting[:token_duration] = 30
    Setting[:unattended_url]    = "http://test.system"
    @request.env["REMOTE_ADDR"] = systems(:ubuntu).ip
    systems(:ubuntu).create_token(:value => "aaaaaa", :expires => Time.now + 5.minutes)
    get :preseed
    assert @response.body.include?("d-i preseed/late_command string wget http://test.system:80/unattended/finish?token=aaaaaa -O /target/tmp/finish.sh && in-target chmod +x /tmp/finish.sh && in-target /tmp/finish.sh")
  end

  # Should this test be moved into renderer_test, as it excercises foreman_url() functionality?
  test "template should not contain https when ssl enabled" do
    @request.env["HTTPS"] = "on"
    @request.env["REMOTE_ADDR"] = systems(:ubuntu).ip
    get :preseed
    assert_no_match(/https/, @response.body)
  end

end
