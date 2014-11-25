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
    post :create, {:config_template => {:name => nil}}, set_session_user
    assert_template 'new'
  end

  test "create valid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    post :create, {:config_template => {:name => "MyConfig"}}, set_session_user
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
    put :update, {:id => config_templates(:pxekickstart).to_param, :config_template => { :name => config_templates(:pxekickstart).name } }, set_session_user
    assert_template 'edit'
  end

  test "update valid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => config_templates(:pxekickstart).to_param, :config_template => {:name => config_templates(:pxekickstart).name}}, set_session_user
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

  test "build menu" do
    ConfigTemplate.find_by_name('PXELinux global default').update_attribute(:template,
      File.read(File.expand_path(File.dirname(__FILE__) + "/../../app/views/unattended/pxe/PXELinux_default.erb")))
    Setting[:unattended_url] = "http://foreman.unattended.url"

    ProxyAPI::TFTP.any_instance.expects(:create_default).with(has_entry(:menu, regexp_matches(/http:\/\/foreman.unattended.url/))).returns(true)
    ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)

    @request.env['HTTP_REFERER'] = config_templates_path
    get :build_pxe_default, {}, set_session_user

    assert_redirected_to config_templates_path
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
