require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
  end

  test "should get edit" do
    org = Organization.new :name => "org1"
    assert org.save!
    get :edit, {:id => org.name}, set_session_user
    assert_response :success
  end

  test "should update organization" do
    name = "org1"
    org = Organization.create :name => name

    post :update, {:commit => "Submit", :id => org.name, :organization => {:name => name} }, set_session_user
    mod_org = Organization.find_by_id(org.id)

    assert mod_org.name = name
    assert_redirected_to organizations_path
  end

  test "should not allow saving another org with same name" do
    name = "org_dup_name"
    org = Organization.new :name => name
    assert org.save!

    put :create, {:commit => "Submit", :organization => {:name => name} }, set_session_user
    assert @response.body.include? "has already been taken"
  end

  test "should delete *empty* organization" do
    name = "org1"
    org = Organization.new :name => name
    assert org.save!

    assert_difference('Organization.count', -1) do
      delete :destroy, {:id => org.name}, set_session_user
      assert_contains flash[:notice], "Successfully destroyed #{name}."
    end
  end
end
