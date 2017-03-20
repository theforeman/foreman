require 'test_helper'

class Api::V2::ProvisioningTemplatesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    templates = ActiveSupport::JSON.decode(@response.body)
    assert !templates.empty?, "Should response with template"
    assert_response :success
  end

  test "should get template detail" do
    get :show, params: { :id => templates(:pxekickstart).to_param }
    assert_response :success
    template = ActiveSupport::JSON.decode(@response.body)
    assert !template.empty?
    assert_equal template["name"], templates(:pxekickstart).name
  end

  test "should create valid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    valid_attrs = { :template => "This is a test template", :template_kind_id => template_kinds(:ipxe).id, :name => "RandomName", :locked => true }
    post :create, params: { :provisioning_template => valid_attrs }
    template = ActiveSupport::JSON.decode(@response.body)
    assert template["name"] == "RandomName"
    assert_response :created
  end

  test "should not create invalid" do
    post :create, params: { :provisioning_template => {:name => "no"} }
    assert_response 422
  end

  test "should report correct error message for invalid association name" do
    post :create, params: { :provisioning_template => {:name => "no", :template_kind_name => 'kind_that_does_not_exist'} }
    assert_response 404
    assert_includes JSON.parse(response.body)['message'], 'Could not find template_kind with name: kind_that_does_not_exist'
  end

  test "should update valid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id              => templates(:pxekickstart).to_param,
                           :provisioning_template => { :template => "blah" } }
    assert_response :ok
  end

  test "should not update invalid" do
    put :update, params: { :id              => templates(:pxekickstart).to_param,
                           :provisioning_template => { :name => "" } }
    assert_response 422
  end

  test "should not destroy template with associated hosts" do
    provisioning_template = templates(:pxekickstart)
    delete :destroy, params: { :id => provisioning_template.to_param }
    assert_response 422
    assert ProvisioningTemplate.unscoped.exists?(provisioning_template.id)
  end

  test "should destroy" do
    provisioning_template = templates(:pxekickstart)
    provisioning_template.os_default_templates.clear
    delete :destroy, params: { :id => provisioning_template.to_param }
    assert_response :ok
    refute ProvisioningTemplate.unscoped.exists?(provisioning_template.id)
  end

  test "should build pxe menu" do
    ProxyAPI::TFTP.any_instance.stubs(:create_default).returns(true)
    ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)
    post :build_pxe_default
    assert_response 200
  end

  test "should add audit comment" do
    ProvisioningTemplate.auditing_enabled = true
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id              => templates(:pxekickstart).to_param,
                           :provisioning_template => { :audit_comment => "aha", :template => "tmp" } }
    assert_response :success
    assert_equal "aha", templates(:pxekickstart).audits.last.comment
  end

  test 'should clone template' do
    original_provisioning_template = templates(:pxekickstart)
    post :clone, params: { :id => original_provisioning_template.to_param,
                           :provisioning_template => {:name => 'MyClone'} }
    assert_response :success
    template = ActiveSupport::JSON.decode(@response.body)
    assert_equal(template['name'], 'MyClone')
    assert_equal(template['template'], original_provisioning_template.template)
  end

  test 'clone name should not be blank' do
    post :clone, params: { :id => templates(:pxekickstart).to_param,
                           :provisioning_template => {:name => ''} }
    assert_response :unprocessable_entity
  end

  test 'export should export the erb of the template' do
    get :export, params: { :id => templates(:pxekickstart).to_param }
    assert_response :success
    assert_equal 'text/plain', response.content_type
    assert_equal templates(:pxekickstart).to_erb, response.body
    assert_equal 'attachment; filename="centos5_3_pxelinux.erb"', response.headers['Content-Disposition']
  end

  test "should show templates from os" do
    get :index, params: { :operatingsystem_id => operatingsystems(:centos5_3).fullname }
    assert_response :success
  end
end
