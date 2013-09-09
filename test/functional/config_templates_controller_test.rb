require 'test_helper'

class ConfigTemplatesControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    ConfigTemplate.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to config_templates_url
  end

  def test_edit
    get :edit, {:id => config_templates(:pxekickstart).to_param}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    ConfigTemplate.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => config_templates(:pxekickstart).to_param}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => config_templates(:pxekickstart).to_param}, set_session_user
    assert_redirected_to config_templates_url
  end

  def test_destroy_should_fail_with_assoicated_hosts
    config_template = config_templates(:pxekickstart)
    delete :destroy, {:id => config_template.to_param}, set_session_user
    assert_redirected_to config_templates_url
    assert ConfigTemplate.exists?(config_template.id)
  end

  def test_destroy
    config_template = config_templates(:pxekickstart)
    config_template.os_default_templates.clear
    delete :destroy, {:id => config_template.to_param}, set_session_user
    assert_redirected_to config_templates_url
    assert !ConfigTemplate.exists?(config_template.id)
  end

  def test_build_menu
    ProxyAPI::TFTP.any_instance.stubs(:create_default_menu).returns(true)
    ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)

    @request.env['HTTP_REFERER'] = config_templates_path
    get :build_pxe_default, {}, set_session_user

    assert_redirected_to config_templates_path
  end

  def test_audit_comment
    ConfigTemplate.auditing_enabled = true
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => config_templates(:pxekickstart).to_param, :config_template => {:audit_comment => "aha", :template => "tmp" }}, set_session_user
    assert_redirected_to config_templates_url
    assert_equal "aha", config_templates(:pxekickstart).audits.last.comment
  end

  def test_history_in_edit
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
