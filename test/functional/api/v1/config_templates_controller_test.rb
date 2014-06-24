require 'test_helper'

class Api::V1::ConfigTemplatesControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    templates = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty templates
    assert_response :success
  end

  test "should get template detail" do
    get :show, { :id => config_templates(:pxekickstart).to_param }
    assert_response :success
    template = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty template
    assert_equal template["config_template"]["name"], config_templates(:pxekickstart).name
  end

  test "should not create invalid" do
    post :create
    assert_response :unprocessable_entity
  end

  test "should create valid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    valid_attrs = { :template => "This is a test template", :template_kind_id => template_kinds(:ipxe).id, :name => "RandomName" }
    post :create, { :config_template => valid_attrs }
    template = ActiveSupport::JSON.decode(@response.body)
    assert template["config_template"]["name"] == "RandomName"
    assert_response :success
  end

  test "should not update invalid" do
    put :update, { :id              => config_templates(:pxekickstart).to_param,
                   :config_template => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should update valid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, { :id              => config_templates(:pxekickstart).to_param,
                   :config_template => { :template => "blah" } }
    template = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
  end

  test "should not destroy template with associated hosts" do
    config_template = config_templates(:pxekickstart)
    delete :destroy, { :id => config_template.to_param }
    assert_response :unprocessable_entity
    assert ConfigTemplate.exists?(config_template.id)
  end

  test "should destroy" do
    config_template = config_templates(:pxekickstart)
    config_template.os_default_templates.clear
    delete :destroy, { :id => config_template.to_param }
    template = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert !ConfigTemplate.exists?(config_template.id)
  end

  test "should build pxe menu" do
    ProxyAPI::TFTP.any_instance.stubs(:create_default).returns(true)
    ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)
    get :build_pxe_default
    assert_response :success
  end

  test "should add audit comment" do
    ConfigTemplate.auditing_enabled = true
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, { :id              => config_templates(:pxekickstart).to_param,
                   :config_template => { :audit_comment => "aha", :template => "tmp" } }
    assert_response :success
    assert_equal "aha", config_templates(:pxekickstart).audits.last.comment
  end

end
