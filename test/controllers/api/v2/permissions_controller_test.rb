require 'test_helper'

class Api::V2::PermissionsControllerTest < ActionController::TestCase
  def assert_response_not_empty
    assert_response :success
    assert_not_empty ActiveSupport::JSON.decode(@response.body)
  end

  test "should get index" do
    get :index
    assert_not_nil assigns(:permissions)
    assert_response_not_empty
  end

  test "should show individual record" do
    get :show, params: { :id => permissions(:view_architectures).to_param }
    assert_response_not_empty
  end

  test "should list resource types" do
    get :resource_types
    assert_not_nil assigns(:resource_types)
    assert_response_not_empty
  end
end
