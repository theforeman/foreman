require 'test_helper'

class Api::V1::RolesControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index
    end
    assert_response :success
    assert_not_nil assigns(:roles)
    roles = ActiveSupport::JSON.decode(@response.body)
    assert !roles.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, {:id => roles(:manager).to_param}
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end


end
