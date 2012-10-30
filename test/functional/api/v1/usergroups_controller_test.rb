require 'test_helper'

class Api::V1::UsergroupsControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:usergroups)
    usergroups = ActiveSupport::JSON.decode(@response.body)
    assert !usergroups.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, {:id => usergroups(:one).to_param}
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

end
