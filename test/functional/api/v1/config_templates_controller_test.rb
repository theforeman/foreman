require 'test_helper'

class Api::V1::ConfigTemplatesControllerTest < ActionController::TestCase

  valid_attrs = { :template => "This is a test template", :template_kind_id => 1, :name => "RandomName" }

  test "should get index" do
    get :index
    templates = ActiveSupport::JSON.decode(@response.body)
    assert !templates.empty?, "Should response with template"
    assert_response :success
  end

  test "should get template detail" do
    get :show, { :id => ConfigTemplate.first.to_param }
    assert_response :success
    template = ActiveSupport::JSON.decode(@response.body)
    assert !template.empty?
    assert_equal template["config_template"]["name"], ConfigTemplate.first.name
  end

  test "should not create invalid" do
    post :create
    assert_response 422
  end

  test "should create valid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    post :create, { :config_template => valid_attrs }
    template = ActiveSupport::JSON.decode(@response.body)
    assert template["config_template"]["name"] == "RandomName"
    assert_response 200
  end

  test "should not update invalid" do
    put :update, { :id              => ConfigTemplate.first.to_param,
                     :config_template => { :name => "" } }
    assert_response 422
  end

  test "should update valid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, { :id              => ConfigTemplate.first.to_param,
                     :config_template => { :template => "blah" } }
    template = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
  end

  test "should not destroy template with associated hosts" do
    config_template = ConfigTemplate.first
    delete :destroy, { :id => config_template.to_param }
    assert_response 422
    assert ConfigTemplate.exists?(config_template.id)
  end

  test "should destroy" do
    config_template = ConfigTemplate.first
    config_template.os_default_templates.clear
    delete :destroy, { :id => config_template.to_param }
    template = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !ConfigTemplate.exists?(config_template.id)
  end

  test "should build pxe menu" do

    ProxyAPI::TFTP.any_instance.stubs(:create_default).returns(true)
    ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)
    get :build_pxe_default
    assert_response 200
  end

  test "should add audit comment" do
    ConfigTemplate.auditing_enabled = true
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, { :id              => ConfigTemplate.first.to_param,
                     :config_template => { :audit_comment => "aha", :template => "tmp" } }
    assert_response :success
    assert_equal "aha", ConfigTemplate.first.audits.last.comment
  end

end
