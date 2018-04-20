require 'test_helper'

class Api::V2::ConfigTemplatesControllerTest < ActionController::TestCase
  setup do
    Foreman::Deprecation.stubs(:api_deprecation_warning).with(regexp_matches(%r{/config_templates were moved to /provisioning_templates}))
  end

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
    valid_attrs = { :template => "This is a test template", :template_kind_id => template_kinds(:ipxe).id, :name => "RandomName" }
    post :create, params: { :config_template => valid_attrs }
    assert_response :created
    template = ActiveSupport::JSON.decode(@response.body)
    assert_equal "RandomName", template["name"]
  end

  test_attributes :pid => '20ccd5c8-98c3-4f22-af50-9760940e5d39'
  test "should create config template with valid name" do
    name = RFauxFactory.gen_alpha
    valid_attrs = { :template => RFauxFactory.gen_alpha, :snippet => true, :name => name }
    assert_difference 'Template.count' do
      post :create, params: { :config_template => valid_attrs }
    end
    assert_response :created
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.key?('name')
    assert_equal name, response["name"]
  end

  test_attributes :pid => '2ec7023f-db4d-49ed-b783-6a4fce79064a'
  test "should not create config template with invalid name" do
    invalid_attrs = { :template => RFauxFactory.gen_alpha, :snippet => true, :name => '' }
    post :create, params: { :config_template => invalid_attrs }
    assert_response :unprocessable_entity
  end

  test "should not create invalid" do
    post :create
    assert_response 422
  end

  test_attributes :pid => '58ccc4ee-5faa-4fb2-bfd0-e19412e230dd'
  test "should update with valid name" do
    template = templates(:pxekickstart)
    new_name = RFauxFactory.gen_alpha
    put :update, params: { :id => template.id, :config_template => { :name => new_name } }
    assert_response :success
    template.reload
    assert_equal new_name, template.name
  end

  test "should update valid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id              => templates(:pxekickstart).to_param,
                           :config_template => { :template => "blah" } }
    assert_response :ok
  end

  test "should update associated operating systems with unwrapped parameters" do
    tpl = templates(:pxekickstart)
    os = operatingsystems(:solaris10)
    refute tpl.operatingsystem_ids.include?(os.id), "OS can't be associated to the config template before the test"

    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => tpl.to_param,
                           :operatingsystem_ids => [os.to_param] }
    assert_response :ok

    tpl.reload
    assert tpl.operatingsystem_ids.include?(os.id), "OS was not assigned to the config template"
  end

  test_attributes :pid => 'f6167dc5-26ba-46d7-b61f-14c290d6a8fa'
  test "should not update with invalid name" do
    put :update, params: { :id => templates(:pxekickstart).to_param, :config_template => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should not destroy template with associated hosts" do
    config_template = templates(:pxekickstart)
    delete :destroy, params: { :id => config_template.to_param }
    assert_response 422
    assert ProvisioningTemplate.unscoped.exists?(config_template.id)
  end

  test_attributes :pid => '1471f17c-4412-4717-a6c4-b57a8d2f8cfd'
  test "should destroy" do
    config_template = templates(:pxekickstart)
    config_template.os_default_templates.clear
    delete :destroy, params: { :id => config_template.to_param }
    assert_response :success
    refute ProvisioningTemplate.unscoped.exists?(config_template.id)
  end

  test "should build pxe menu" do
    ProxyAPI::TFTP.any_instance.stubs(:create_default).returns(true)
    ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)
    post :build_pxe_default
    response_body = ActiveSupport::JSON.decode(@response.body)
    assert_response 200
    assert response_body.is_a?(Hash)
    refute response_body['message'].nil?
  end

  test "should add audit comment" do
    ProvisioningTemplate.auditing_enabled = true
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id              => templates(:pxekickstart).to_param,
                           :config_template => { :audit_comment => "aha", :template => "tmp" } }
    assert_response :success
    assert_equal "aha", templates(:pxekickstart).audits.last.comment
  end

  test 'should clone template' do
    original_config_template = templates(:pxekickstart)
    post :clone, params: { :id => original_config_template.to_param,
                           :config_template => {:name => 'MyClone'} }
    assert_response :success
    template = ActiveSupport::JSON.decode(@response.body)
    assert_equal(template['name'], 'MyClone')
    assert_equal(template['template'], original_config_template.template)
  end

  test 'clone name should not be blank' do
    post :clone, params: { :id => templates(:pxekickstart).to_param,
                           :config_template => {:name => ''} }
    assert_response :unprocessable_entity
  end

  test "should show templates from os" do
    get :index, params: { :operatingsystem_id => operatingsystems(:centos5_3).fullname }
    assert_response :success
  end

  test "should list templates with non-admin user" do
    setup_user('view', 'provisioning_templates')
    get :index, session: set_session_user.merge(:user => User.current.id)
    assert_response :success
    templates = ActiveSupport::JSON.decode(@response.body)
    assert !templates.empty?, "Should respond with templates"
  end

  test "should show template with non-admin user" do
    setup_user('view', 'provisioning_templates')
    templates(:pxekickstart).organizations = User.current.organizations
    templates(:pxekickstart).locations = User.current.locations
    get :show, params: { :id => templates(:pxekickstart).to_param }, session: set_session_user.merge(:user => User.current.id)
    assert_response :success
  end
end
