require 'test_helper'

class Api::V1::AuthSourceLdapsControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:auth_source_ldaps)
    auth_source_ldaps = ActiveSupport::JSON.decode(@response.body)
    assert !auth_source_ldaps.empty?
  end

  test "should show auth_source_ldap" do
    as_user :admin do
      get :show, {:id => auth_sources(:one).to_param}
    end
    assert_response :success
  end

end
