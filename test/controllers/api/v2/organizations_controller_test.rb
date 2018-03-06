require 'test_helper'
require 'rfauxfactory'

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
    user.organizations = [ org1 ]
    filter = FactoryBot.create(:filter, :permissions => [ Permission.find_by_name(:view_organizations) ])
    user.roles << filter.role
    as_user user do
      get :index
      assert_response :success
      assert_includes assigns(:organizations), org1
      refute_includes assigns(:organizations), org2
    end
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
    put :update, params: { :id => org.to_param, :organization => { :ignore_types => [ 'ProvisioningTemplate' ] } }
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
    assert_raises_with_message(RuntimeError, 'Unknown Content-Type') do
      post :create, params: { :organization => {:name => "foo organization"} }, as: 'text/plain'
    end
  end

  test "create with name" do
    name = RFauxFactory.gen_alpha
    post :create, params: { :organization => {:name => name} }
    assert_response :success
    response = JSON.parse(@response.body)
    assert response.key?('name')
    assert_equal response['name'], name
  end

  test "create with name and description" do
    name = RFauxFactory.gen_alpha
    post :create, params: {:organization => { :name => name, :description => name } }
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal result["name"], name
    assert_equal result["description"], name
  end

  test "should not create with same name" do
    name = Organization.first.name
    post :create, params: { :organization => { :name => name} }
    assert_response :unprocessable_entity
    assert_include @response.body, "Name has already been taken"
  end

  test "search organization" do
    organization = Organization.first
    get :index, params: { :search =>  "name = \"#{organization.name}\"",  :format => 'json' }
    assert_response :success
    response = JSON.parse(@response.body)
    assert_equal response['results'].length, 1
    assert_equal response['results'][0]['name'], organization.name
    assert_equal response['results'][0]['id'], organization.id
  end

  test "update name" do
    name = RFauxFactory.gen_alpha
    new_name = RFauxFactory.gen_alpha 20
    organization = FactoryBot.create(:organization, :name => name)
    post :update, params: { :id => organization.id, :organization => { :name => new_name} }
    assert_response :success
    organization.reload
    assert_equal organization.name, new_name
  end

  test "update description" do
    organization = Organization.first
    new_description = RFauxFactory.gen_alpha
    post :update, params: { :id => organization.id, :organization => { :description => new_description} }
    assert_response :success
    organization.reload
    assert_equal organization.description, new_description
  end

  test "update name and description" do
    name = RFauxFactory.gen_alpha
    description = RFauxFactory.gen_alpha
    organization = FactoryBot.create(:organization, :name => name, :description => description)
    new_name = RFauxFactory.gen_alpha
    new_description = RFauxFactory.gen_alpha
    post :update, params: { :id => organization.id, :organization => { :name => new_name, :description => new_description} }
    assert_response :success
    organization.reload
    assert_equal organization.name, new_name
    assert_equal organization.description, new_description
  end
end
