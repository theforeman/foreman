require 'test_helper'

class Api::V1::SubnetsControllerTest < ActionController::TestCase
  
  valid_attrs = {:name => 'QA2', :network => '10.35.2.27', :mask => '255.255.255.0'}

  def test_index
    as_admin { get :index }
    subnets = ActiveSupport::JSON.decode(@response.body)
    assert subnets.is_a?(Array)
    assert_response :success
    assert !subnets.empty?

  end

  test "should show individual record" do
    as_user :admin do
      get :show, {:id => subnets(:one).to_param}
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create subnet" do
    as_user :admin do
      assert_difference('Subnet.count') do
        post :create, {:subnet => valid_attrs}
      end
    end
    assert_response :success
  end

  test "should update subnet" do
    as_user :admin do
      put :update, {:id => subnets(:one).to_param, :subnet => {} }
    end
    assert_response :success
  end

  test "should destroy subnets" do
    as_user :admin do
      assert_difference('Subnet.count', -1) do
        delete :destroy, {:id => subnets(:three).to_param}
      end
    end
    assert_response :success
  end

  test "should NOT destroy subnet that is in use" do
    as_user :admin do
      assert_difference('Subnet.count', 0) do
        delete :destroy, {:id => subnets(:one).to_param}
      end
    end
    assert_response :unprocessable_entity
  end


end
