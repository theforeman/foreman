require 'test_helper'

class ConfigTemplatesControllerTest < ActionController::TestCase
  test "index" do
    get :index, {}, set_session_user
    assert_template 'index'
  end

  test "new" do
    get :new, {}, set_session_user
    assert_template 'new'
  end

  test "create invalid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  test "create valid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to config_templates_url
  end

  test "edit" do
    get :edit, {:id => config_templates(:pxekickstart).to_param}, set_session_user
    assert_template 'edit'
  end

  test "lock" do
    @request.env['HTTP_REFERER'] = config_templates_path
    get :lock, {:id => config_templates(:pxekickstart).to_param}, set_session_user
    assert_redirected_to config_templates_path
    assert_equal ConfigTemplate.find(config_templates(:pxekickstart).id).locked, true
  end

  test "unlock" do
    @request.env['HTTP_REFERER'] = config_templates_path
    get :unlock, {:id => config_templates(:locked).to_param}, set_session_user
    assert_redirected_to config_templates_path
    assert_equal ConfigTemplate.find(config_templates(:locked).id).locked, false
  end

  test "clone" do
    get :clone, {:id => config_templates(:pxekickstart).to_param}, set_session_user
    assert_template 'new'
  end

  test "update invalid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => config_templates(:pxekickstart).to_param}, set_session_user
    assert_template 'edit'
  end

  test "update valid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => config_templates(:pxekickstart).to_param}, set_session_user
    assert_redirected_to config_templates_url
  end

  test "destroy should fail with assoicated hosts" do
    config_template = config_templates(:pxekickstart)
    delete :destroy, {:id => config_template.to_param}, set_session_user
    assert_redirected_to config_templates_url
    assert ConfigTemplate.exists?(config_template.id)
  end

  test "destroy" do
    config_template = config_templates(:pxekickstart)
    config_template.os_default_templates.clear
    delete :destroy, {:id => config_template.to_param}, set_session_user
    assert_redirected_to config_templates_url
    assert !ConfigTemplate.exists?(config_template.id)
  end

  context "build pxe menu" do
    setup do
      proxy = smart_proxies(:two)
      proxy.features = []
      proxy.save!

      template = File.read(File.expand_path(File.dirname(__FILE__) + "/../../app/views/unattended/pxe/PXELinux_default.erb"))
      ConfigTemplate.find_by_name('PXELinux global default').update_attribute(:template, template)

      ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)
      Setting[:unattended_url] = "http://foreman.unattended.url"
      @request.env['HTTP_REFERER'] = config_templates_path
    end

    test "without templates proxy" do
      FactoryGirl.create :tftp_smart_proxy
      ProxyAPI::TFTP.any_instance.expects(:create_default).with(has_entry(:menu, regexp_matches(/ks=http:\/\/foreman.unattended.url:80\/unattended\/template/))).returns(true)

      get :build_pxe_default, {}, set_session_user
      assert_redirected_to config_templates_path
    end

    test "with templates proxy" do
      FactoryGirl.create :template_smart_proxy
      ProxyAPI::Template.any_instance.stubs(:template_url).returns('http://proxy.unattended.url:8000')
      ProxyAPI::TFTP.any_instance.expects(:create_default).with(has_entry(:menu, regexp_matches(/ks=http:\/\/proxy.unattended.url:8000\/unattended\/template/))).returns(true)

      get :build_pxe_default, {}, set_session_user
      assert_redirected_to config_templates_path
    end
  end

  test "audit comment" do
    ConfigTemplate.auditing_enabled = true
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => config_templates(:pxekickstart).to_param, :config_template => {:audit_comment => "aha", :template => "tmp" }}, set_session_user
    assert_redirected_to config_templates_url
    assert_equal "aha", config_templates(:pxekickstart).audits.last.comment
  end

  test "history in edit" do
    setup_users
    ConfigTemplate.auditing_enabled = true
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    template = config_templates(:pxekickstart)
    template.template = template.template.upcase
    assert template.save
    assert_equal template.audits.count, 1
    get :edit, {:id => template.to_param}, set_session_user

    assert @response.body.match('audit-content')
  end
end
