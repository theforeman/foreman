require 'test_helper'

class Api::V1::ComputeResourcesControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:compute_resources)
    compute_resources = ActiveSupport::JSON.decode(@response.body)
    assert !compute_resources.empty?
  end

  test "should show compute_resource" do
    as_user :admin do
      get :show, {:id => compute_resources(:one).to_param}
    end
    assert_response :success
  end

end
