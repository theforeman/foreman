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
end
