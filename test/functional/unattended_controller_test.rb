require 'test_helper'

class UnattendedControllerTest < ActionController::TestCase
  setup do
    Host::Managed.any_instance.stubs(:handle_ca).returns(true)
  end

  test "should get a kickstart" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{hosts(:redhat).mac}"
    get :provision
    assert_response :success
  end

  test "should get a kickstart even if not using the first NIC" do
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "unused NIC"
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_3"] = "eth4 #{hosts(:redhat).mac}"
    get :provision
    assert_response :success
  end

  test "should get a kickstart even if we are behind a loadbalancer" do
    @request.env["HTTP_X_FORWARDED_FOR"] = hosts(:redhat).ip
    @request.env["REMOTE_ADDR"] = "127.0.0.1"
    get :provision
    assert_response :success
  end

  test "should get a preseed finish script" do
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    get :finish
    assert_response :success
  end

  test "should get a preseed finish script with multiple ips in the request header" do
    @request.env["REMOTE_ADDR"] = [hosts(:ubuntu).ip, '1.2.3.4']
    get :finish
    assert_response :success
  end

  test "should get a preseed" do
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    get :provision
    assert_response :success
  end

  test "unattended files content type should be text/plain" do
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    get :provision
    assert_response :success
    assert @response.headers["Content-Type"].match("text/plain")
  end

  test "should set @static when requested" do
    Setting[:safemode_render]=false
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{hosts(:redhat).mac}"
    get(:provision, 'static' => 'true')
    assert_match(%r{static:true}, @response.body)
  end

  test "should support spoof" do
    get :provision, {:spoof => hosts(:ubuntu).ip}, set_session_user
    assert_response :success
  end

  test "should not render spoof when user is not logged in" do
    get :provision, {:spoof => hosts(:ubuntu).ip}
    assert_response :redirect
  end

  test "should not render hostname spoof when user is not logged in" do
    get :provision, {:hostname => hosts(:ubuntu).fqdn}
    assert_response :redirect
  end

  test "should not render hostname spoof when hostname is empty" do
    get :provision, {:hostname => nil}, set_session_user
    assert_response 404
  end

  test "should not render hostname spoof when spoof is empty" do
    get :provision, {:spoof => nil}, set_session_user
    assert_response 404
  end

  test "should support spoof using hostname" do
    get :provision, {:hostname => hosts(:ubuntu).name}, set_session_user
    assert_response :success
    assert_equal hosts(:ubuntu).name, assigns(:host).name
  end

  test "should provide pxe config for redhat" do
    get :PXELinux, {:spoof => hosts(:redhat).ip}, set_session_user
    assert_response :success
  end

  test "should provide pxe config for debian" do
    get :PXELinux, {:spoof => hosts(:ubuntu).ip}, set_session_user
    assert_response :success
  end

  test "should render spoof pxelinux for a host" do
    get :PXELinux, {:spoof => hosts(:redhat).ip}, set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
    assert_response :success
  end

  test "should render spoof pxegrub for a host" do
    get :PXEGrub, {:spoof => hosts(:redhat).ip}, set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
    assert_response :success
  end

  test "should render spoof iPXE for a host" do
    get :iPXE, {:spoof => hosts(:redhat).ip}, set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
    assert_response :success
  end

  test "should render spoof gpxe for a host" do
    get :gPXE, {:spoof => hosts(:redhat).ip}, set_session_user
    assert assigns(:initrd)
    assert assigns(:kernel)
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
    get :provision
    assert_response :method_not_allowed
  end

  test "should not provide unattended files to hosts which we don't know about" do
    get :provision
    assert_response :not_found
  end

  test "should not provide unattended files to hosts which don't have an assign os" do
    setup_users

    hosts(:otherfullhost).update_attribute(:operatingsystem_id, nil)
    @request.env["HTTP_X_RHN_PROVISIONING_MAC_0"] = "eth0 #{hosts(:otherfullhost).mac}"
    get :provision
    assert_response :conflict
  end

  test "template with hostgroup should be rendered" do
    get :template, {:id => "MyString", :hostgroup => "Common"}
    assert_response :success
  end

  test "template with hostgroup should be identified as hostgroup provisioning" do
    ConfigTemplate.any_instance.stubs(:template).returns("type:<%= @provisioning_type %>")
    get :template, {:id => "MyString2", :hostgroup => "Common"}
    assert_response :success
    assert_match(%r{type:hostgroup}, @response.body)
  end

  test "template with host should be identified as host provisioning" do
    ConfigTemplate.any_instance.stubs(:template).returns("type:<%= @provisioning_type %>")
    get :provision, {:hostname => hosts(:ubuntu).name}, set_session_user
    assert_response :success
    assert_match(%r{type:host\z}, @response.body)
  end

  test "template with hostgroup should be rendered even if both have periods in their names" do
    config_templates(:mystring).update_attributes(:name => 'My.String')
    hostgroups(:common).update_attributes(:name => 'Com.mon')
    assert_routing '/unattended/template/My.String/Com.mon', {:controller => 'unattended', :action => 'template', :id => "My.String", :hostgroup => "Com.mon"}
    get :template, {:id => "My.String", :hostgroup => "Com.mon"}
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
    get :provision, {'token' => hosts(:ubuntu).token.value }
    assert_response :success
  end

  context "location or organizations are not enabled" do

    before do
      SETTINGS[:locations_enabled] = false
      SETTINGS[:organizations_enabled] = false
    end

    after do
      SETTINGS[:locations_enabled] = true
      SETTINGS[:organizations_enabled] = true
    end

    test "hosts with mismatched ip and update_ip=false should have the old ip" do
      disable_orchestration # avoids dns errors
      Setting[:token_duration] = 30
      Setting[:update_ip_from_built_request] = false
      @request.env["REMOTE_ADDR"] = '127.0.0.1'
      h=hosts(:ubuntu2)
      h.create_token(:value => "aaaaaa", :expires => Time.now + 5.minutes)
      get :built, {'token' => h.token.value }
      h_new=Host.find_by_name(h.name)
      assert_response :success
      assert_equal h.ip, h_new.ip
    end

    test "hosts with mismatched ip and update_ip true should have the new ip" do
      disable_orchestration # avoids dns errors
      Setting[:token_duration] = 30
      Setting[:update_ip_from_built_request] = true
      @request.env["REMOTE_ADDR"] = '2.3.4.199'
      h=hosts(:ubuntu2)
      assert_equal '2.3.4.106', h.ip
      h.create_token(:value => "aaaaab", :expires => Time.now + 5.minutes)
      get :built, {'token' => h.token.value }
      h_new=Host.find_by_name(h.name)
      assert_response :success
      assert_equal '2.3.4.199', h_new.ip
    end

    test "hosts with mismatched ip and update_ip true and a duplicate ip should succeed with no ip update" do
      disable_orchestration # avoids dns errors
      Setting[:token_duration] = 30
      Setting[:update_ip_from_built_request] = true
      @request.env["REMOTE_ADDR"] = hosts(:redhat).ip
      h=hosts(:ubuntu2)
      h.create_token(:value => "aaaaac", :expires => Time.now + 5.minutes)
      get :built, {'token' => h.token.value }
      assert_response :success
      h_new=Host.find_by_name(h.name)
      assert_equal h.ip, h_new.ip
    end

    # Should this test be moved into renderer_test, as it excercises foreman_url() functionality?
    test "template should contain tokens when tokens enabled and present for the host" do
      Setting[:token_duration] = 30
      Setting[:unattended_url]    = "http://test.host"
      @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
      hosts(:ubuntu).create_token(:value => "aaaaaa", :expires => Time.now + 5.minutes)
      get :provision
      assert @response.body.include?("http://test.host:80/unattended/finish?token=aaaaaa")
    end
  end # end of context "location or organizations are not enabled"

  # Should this test be moved into renderer_test, as it excercises foreman_url() functionality?
  test "template should not contain https when ssl enabled" do
    @request.env["HTTPS"] = "on"
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    get :provision
    assert_match(%r{http://}, @response.body)
    assert_no_match(%r{https://}, @response.body)
  end

  test "should return and log error when template not found" do
    @request.env["REMOTE_ADDR"] = hosts(:ubuntu).ip
    Host::Managed.any_instance.expects(:configTemplate).returns(nil)
    Rails.logger.expects(:error).with(regexp_matches(/unable to find provision template/))
    get :provision
    assert_response :not_found
  end

end
