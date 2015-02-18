require 'test_helper'

class Api::V2::ConfigTemplatesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    templates = ActiveSupport::JSON.decode(@response.body)
    assert !templates.empty?, "Should response with template"
    assert_response :success
  end

  test "should get template detail" do
    get :show, { :id => config_templates(:pxekickstart).to_param }
    assert_response :success
    template = ActiveSupport::JSON.decode(@response.body)
    assert !template.empty?
    assert_equal template["name"], config_templates(:pxekickstart).name
  end

  test "should create valid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    valid_attrs = { :template => "This is a test template", :template_kind_id => template_kinds(:ipxe).id, :name => "RandomName" }
    post :create, { :config_template => valid_attrs }
    template = ActiveSupport::JSON.decode(@response.body)
    assert template["name"] == "RandomName"
    assert_response 200
  end

  test "should not create invalid" do
    post :create
    assert_response 422
  end

  test "should update valid" do
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, { :id              => config_templates(:pxekickstart).to_param,
                   :config_template => { :template => "blah" } }
    assert_response :ok
  end

  test "should not update invalid" do
    put :update, { :id              => config_templates(:pxekickstart).to_param,
                   :config_template => { :name => "" } }
    assert_response 422
  end

  test "should not destroy template with associated hosts" do
    config_template = config_templates(:pxekickstart)
    delete :destroy, { :id => config_template.to_param }
    assert_response 422
    assert ConfigTemplate.exists?(config_template.id)
  end

  test "should destroy" do
    config_template = config_templates(:pxekickstart)
    config_template.os_default_templates.clear
    delete :destroy, { :id => config_template.to_param }
    assert_response :ok
    refute ConfigTemplate.exists?(config_template.id)
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
    put :update, { :id              => config_templates(:pxekickstart).to_param,
                   :config_template => { :audit_comment => "aha", :template => "tmp" } }
    assert_response :success
    assert_equal "aha", config_templates(:pxekickstart).audits.last.comment
  end

  test 'should clone template' do
    original_config_template = config_templates(:pxekickstart)
    post :clone, { :id => original_config_template.to_param,
                   :config_template => {:name => 'MyClone'} }
    assert_response :success
    template = ActiveSupport::JSON.decode(@response.body)
    assert_equal(template['name'], 'MyClone')
    assert_equal(template['template'], original_config_template.template)
  end

  test 'clone name should not be blank' do
    post :clone, { :id => config_templates(:pxekickstart).to_param,
                   :config_template => {:name => ''} }
    assert_response :unprocessable_entity
  end
end
