require 'test_helper'

class Api::V1::ComputeResourcesControllerTest < ActionController::TestCase

  valid_attrs = {:name => 'special_compute', :provider => 'EC2', :url => 'eu-west1'}

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
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create compute_resource" do
    as_user :admin do
      assert_difference('ComputeResource.count', 1) do
        post :create, {:compute_resource => valid_attrs}
      end
    end
    assert_response :success
  end

  test "should destroy compute_resource" do
    as_user :admin do
      assert_difference('ComputeResource.count', -1) do
        delete :destroy, {:id => compute_resources(:yourcompute).id}
      end
    end
    assert_response :success
  end

end
