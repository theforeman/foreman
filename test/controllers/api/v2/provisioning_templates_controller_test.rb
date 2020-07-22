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

  test "should create valid and locked" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    valid_attrs = { :template => "This is a test template", :template_kind_id => template_kinds(:ipxe).id, :name => "RandomName", :locked => true }
    post :create, params: { :provisioning_template => valid_attrs }
    assert_response :created
    template = ActiveSupport::JSON.decode(@response.body)
    assert_equal "RandomName", template["name"]
  end

  test "should not create invalid" do
    post :create, params: { :provisioning_template => {:name => "no"} }
    assert_response 422
  end

  test_attributes :pid => 'd7309be8-b5c9-4f77-8c4e-e9f2b8982076'
  test "should create with template kind and min attributes" do
    template_kind = template_kinds(:pxegrub)
    valid_attrs = { :template => 'This is a test template', :template_kind_id => template_kind.id, :name => 'new_template' }
    post :create, params: { :provisioning_template => valid_attrs }
    assert_response :created
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.key?('template_kind_id')
    assert template_kind.id, response["template_kind_id"]
  end

  test_attributes :pid => '4a1410e4-aa3c-4d27-b062-089e34722bd9'
  test "should create with template kind name" do
    template_kind = template_kinds(:pxegrub)
    valid_attrs = { :template => 'This is a test template', :template_kind_name => template_kind.name, :name => 'new_template' }
    post :create, params: { :provisioning_template => valid_attrs }
    assert_response :created
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.key?('template_kind_id')
    assert template_kind.id, response["template_kind_id"]
    assert response.key?('template_kind_name')
    assert template_kind.name, response["template_kind_name"]
  end

  test_attributes :pid => 'e6de9ceb-fe4b-43ce-b7e3-5453ca4bd164'
  test "should report correct error message for invalid association name" do
    post :create, params: { :provisioning_template => {:name => "no", :template_kind_name => 'kind_that_does_not_exist'} }
    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)['error']['message'], 'Could not find template_kind with name: kind_that_does_not_exist'
  end

  test "should update valid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => templates(:pxekickstart).to_param,
                           :provisioning_template => { :template => "blah" } }
    assert_response :ok
  end

  test "should not update invalid" do
    put :update, params: { :id => templates(:pxekickstart).to_param,
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
    put :update, params: { :id => templates(:pxekickstart).to_param,
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
    assert_equal 'text/plain', response.media_type
    assert_equal templates(:pxekickstart).to_erb, response.body
    assert_match /attachment; filename="centos5_3_pxelinux.erb"/, response.headers['Content-Disposition']
  end

  test "should show templates from os" do
    get :index, params: { :operatingsystem_id => operatingsystems(:centos5_3).fullname }
    assert_response :success
  end

  test "should import provisioning template" do
    snippet = FactoryBot.create(:provisioning_template, :snippet)
    post :import, params: { :provisioning_template => { :name => snippet.name, :template => "<%#\nsnippet: true\n-%>\nbbbb"} }
    assert_response :success
    assert_match 'bbbb', ProvisioningTemplate.unscoped.find_by_name(snippet.name).template
  end

  test "should override taxonomies when importing a template" do
    org = FactoryBot.create(:organization)
    loc = FactoryBot.create(:location)
    name = "taxonomy override test name"
    template = "<%#\nkind: PXELinux\nname: #{name}\nmodel: ProvisioningTemplate\norganizations:\n - #{org.name}\nlocations:\n - #{loc.name}\n%>\ntest"
    changed_org = FactoryBot.create(:organization)
    changed_loc = FactoryBot.create(:location)
    post :import, params: { :provisioning_template => { :name => name,
                                                        :template => template,
                                                        :organization_ids => [changed_org.id],
                                                        :location_ids => [changed_loc.id] },
                            :options => { :associate => 'new' } }
    assert_response :success
    imported = Template.find_by :name => name
    assert_equal 1, imported.organizations.count
    assert_equal changed_org, imported.organizations.first

    assert_equal 1, imported.locations.count
    assert_equal changed_loc, imported.locations.first
  end

  test_attributes :pid => '392b3782-a3ee-40db-954c-a85d5b452abb'
  test "should create provisioning template with template_combinations" do
    name = RFauxFactory.gen_alpha
    valid_attrs = {
      :name => name, :template => RFauxFactory.gen_alpha, :template_kind_id => template_kinds(:ipxe).id,
      :template_combinations_attributes => [
        { :hostgroup_id => hostgroups(:common).id, :environment_id => environments(:production).id },
      ]
    }
    post :create, params: { :provisioning_template => valid_attrs }
    assert_response :created
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.key?('id')
    assert response.key?('template_combinations')
    template_combinations = response['template_combinations']
    assert_equal 1, template_combinations.length
    template_combination = TemplateCombination.find(template_combinations[0]['id'])
    assert_equal response['id'], template_combination.provisioning_template_id
  end

  describe 'global registration template' do
    test "should get template" do
      get :global_registration
      assert_response :success
      assert_equal @response.body, templates(:global_registration).template
    end

    test "should render not_found" do
      Setting::Provisioning.any_instance.stubs(:value).returns('not-existing-template')
      get :global_registration
      assert_response :not_found
      assert_equal @response.body, "Global Registration Template not found"
    end

    test "should render error when template is invalid" do
      Foreman::Renderer::Source::Database.any_instance.stubs(:content).returns("<% asda =!?== '2 % %>")
      get :global_registration
      assert_response :internal_server_error
    end
  end
end
