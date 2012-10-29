require 'test_helper'

class Api::V1::PtablesControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:ptables)
    ptables = ActiveSupport::JSON.decode(@response.body)
    assert !ptables.empty?
  end

  test "should show architecture" do
    as_user :admin do
      get :show, {:id => ptables(:one).to_param}
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end


end
