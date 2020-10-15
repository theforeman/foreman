require 'test_helper'

class Api::V2::OrganizationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organizations)
  end

  test "index respects taxonomies" do
    org1 = FactoryBot.create(:organization)
    org2 = FactoryBot.create(:organization)
    user = FactoryBot.create(:user)
    user.organizations = [org1]
    filter = FactoryBot.create(:filter, :permissions => [Permission.find_by_name(:view_organizations)])
    user.roles << filter.role
    as_user user do
      get :index
      assert_response :success
      assert_includes assigns(:organizations), org1
      refute_includes assigns(:organizations), org2
    end
  end

  test "non admin user can list orgs with (default) organization set filtered by location" do
    org1 = FactoryBot.create(:organization)
    loc1 = FactoryBot.create(:location)
    loc2 = FactoryBot.create(:location)
    org2 = FactoryBot.create(:organization, :location_ids => [loc1.id])
    org3 = FactoryBot.create(:organization, :location_ids => [loc2.id])
    user = FactoryBot.create(:user)
    user.organizations = [org1, org2]
    user.locations = [loc1, loc2]
    filter = FactoryBot.create(:filter, :permissions => [Permission.find_by_name(:view_organizations)])
    user.roles << filter.role
    as_user user do
      get :index, params: { :organization_id => org1.id, :location_ids => loc1.id }
      assert_response :success
      assert_includes assigns(:organizations), org1
      assert_includes assigns(:organizations), org2
      refute_includes assigns(:organizations), org3
    end
  end

  test 'show should deprecate environments' do
    get :show, params: { id: FactoryBot.create(:organization).to_param, format: 'json' }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert show_response['deprecations']&.key?('environments'), 'Response should have message about deprecated environments.'
  end

  test "user without view_params permission can't see organization parameters" do
    org_with_parameter = FactoryBot.create(:organization, :with_parameter)
    setup_user "view", "organizations"
    get :show, params: { :id => org_with_parameter.to_param, :format => 'json' }
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see organization parameters" do
    org_with_parameter = FactoryBot.create(:organization, :with_parameter)
    org_with_parameter.users << users(:one)
    setup_user "view", "organizations"
    setup_user "view", "params"
    get :show, params: { :id => org_with_parameter.to_param, :format => 'json' }
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  test "organization ignore types can be modified" do
    org = FactoryBot.create(:organization)
    put :update, params: { :id => org.to_param, :organization => { :ignore_types => ['ProvisioningTemplate'] } }
    org.reload
    assert_includes org.ignore_types, 'ProvisioningTemplate'
  end

  context 'hidden parameters' do
    test "should show a organization parameter as hidden unless show_hidden_parameters is true" do
      org = FactoryBot.create(:organization)
      org.organization_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => org.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a organization parameter as unhidden when show_hidden_parameters is true" do
      org = FactoryBot.create(:organization)
      org.organization_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => org.id, :show_hidden_parameters => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should update existing organization parameters" do
    organization = FactoryBot.create(:organization)
    param_params = { :name => "foo", :value => "bar" }
    organization.organization_parameters.create!(param_params)
    put :update, params: { :id => organization.id, :organization => { :organization_parameters_attributes => [{ :name => param_params[:name], :value => "new_value" }] } }
    assert_response :success
    assert param_params[:name], organization.parameters[param_params[:name]]
  end

  test "should delete existing organization parameters" do
    organization = FactoryBot.create(:organization)
    param_1 = { :name => "foo", :value => "bar" }
    param_2 = { :name => "boo", :value => "test" }
    organization.organization_parameters.create!([param_1, param_2])
    put :update, params: { :id => organization.id, :organization => { :organization_parameters_attributes => [{ :name => param_1[:name], :value => "new_value" }] } }
    assert_response :success
    assert_equal 1, organization.reload.organization_parameters.count
  end

  test "should not update invalid organization" do
    put :update, params: { :id => Organization.first.id, :organization => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should not create invalid organization" do
    post :create, params: { :organization => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should not create with content type text plain" do
    post :create, params: { :organization => {:name => "foo organization"} }, as: Mime::LOOKUP['text/plain']
    assert_response :unsupported_media_type
  end

  test "create with name" do
    name = RFauxFactory.gen_alpha
    post :create, params: { :organization => {:name => name} }
    assert_response :success, "creation with name: #{name} failed with code: #{@response.code}"
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert_equal response['name'], name
  end

  test "create with name and description" do
    name = RFauxFactory.gen_alpha
    description = RFauxFactory.gen_utf8(1024)
    post :create, params: {:organization => { :name => name, :description => description } }
    assert_response :success, "creation with name: '#{name}' and description: '#{description}' failed with code: #{@response.code}"
    result = JSON.parse(@response.body)
    assert_equal result["name"], name
    assert_equal result["description"], description
  end

  test "should not create with same name" do
    name = Organization.first.name
    post :create, params: { :organization => { :name => name} }
    assert_response :unprocessable_entity
    assert_include @response.body, "Name has already been taken"
  end

  test "search organization" do
    organization = Organization.first
    get :index, params: { :search => "name = \"#{organization.name}\"", :format => 'json' }
    assert_response :success, "search organization name: '#{organization.name}' failed with code: #{@response.code}"
    response = JSON.parse(@response.body)
    assert_equal response['results'].length, 1
    assert_equal response['results'][0]['name'], organization.name
    assert_equal response['results'][0]['id'], organization.id
  end

  test "update name" do
    new_name = RFauxFactory.gen_alpha 20
    organization = FactoryBot.create(:organization)
    post :update, params: { :id => organization.id, :organization => { :name => new_name} }
    assert_response :success, "update with name: '#{new_name}' failed with code: #{@response.code}"
    organization.reload
    assert_equal organization.name, new_name
  end

  test "update description" do
    organization = Organization.first
    new_description = RFauxFactory.gen_utf8(1024)
    post :update, params: { :id => organization.id, :organization => { :description => new_description} }
    assert_response :success, "update with description: '#{new_description}' failed with code: #{@response.code}"
    organization.reload
    assert_equal organization.description, new_description
  end

  test "update name and description" do
    organization = FactoryBot.create(:organization)
    new_name = RFauxFactory.gen_alpha
    new_description = RFauxFactory.gen_alpha
    post :update, params: { :id => organization.id, :organization => { :name => new_name, :description => new_description} }
    assert_response :success, "update with name: '#{new_name}', description: '#{new_description}' failed with code: #{@response.code}"
    organization.reload
    assert_equal organization.name, new_name
    assert_equal organization.description, new_description
  end

  test "org admin should not create organizations by default" do
    org = taxonomies(:organization1)
    # Note: org admin role has no default permissions in unit-tests, for real functionality we have to load them before.
    load File.join(Rails.root, '/db/seeds.d/030-permissions.rb')
    load File.join(Rails.root, '/db/seeds.d/040-roles.rb')
    default_org_admin_role = Role.find_by_name('Organization admin')
    refute_empty default_org_admin_role.permissions
    org_admin_role = default_org_admin_role.clone(:name => 'new_org_admin', :organizations => [org])
    org_admin_role.save!
    org_admin_user = User.create(
      :login => "foo",
      :mail => "foo@bar.com",
      :auth_source => auth_sources(:one),
      :roles => [org_admin_role],
      :organizations => [org]
    )
    as_user org_admin_user do
      post :create, params: { :organization => { :name => 'org1'} }
    end
    assert_response :forbidden
    assert_match 'Missing one of the required permissions: create_organizations', @response.body
  end

  test "should add location to organization" do
    organization = FactoryBot.create(:organization)
    location = FactoryBot.create(:location)
    put :update, params: { :id => organization.id, :organization => { :location_ids => [location.id] } }
    assert_response :success
    assert_contains organization.locations, location
  end
end
