require 'test_helper'

class Api::V2::OrganizationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:organizations)
  end

  test "index respects taxonomies" do
    org1 = FactoryGirl.create(:organization)
    org2 = FactoryGirl.create(:organization)
    user = FactoryGirl.create(:user)
    user.organizations = [ org1 ]
    filter = FactoryGirl.create(:filter, :permissions => [ Permission.find_by_name(:view_organizations) ])
    user.roles << filter.role
    as_user user do
      get :index, { }
      assert_response :success
      assert_includes assigns(:organizations), org1
      refute_includes assigns(:organizations), org2
    end
  end

  test "user without view_params permission can't see organization parameters" do
    setup_user "view", "organizations"
    org_with_parameter = FactoryGirl.create(:organization, :with_parameter)
    get :show, {:id => org_with_parameter.to_param, :format => 'json'}
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see organization parameters" do
    setup_user "view", "organizations"
    setup_user "view", "params"
    org_with_parameter = FactoryGirl.create(:organization, :with_parameter)
    get :show, {:id => org_with_parameter.to_param, :format => 'json'}
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  test "organization ignore types can be modified" do
    org = FactoryGirl.create(:organization)
    put :update, { :id => org.to_param, :organization => { :ignore_types => [ 'ProvisioningTemplate' ] } }
    org.reload
    assert_includes org.ignore_types, 'ProvisioningTemplate'
  end
end
