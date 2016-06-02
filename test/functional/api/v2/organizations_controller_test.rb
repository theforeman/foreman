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
end
