require 'test_helper'

class Api::V1::CommonParametersControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'special_key', :value => '123' }

  test "should get index" do
    as_user :admin do
      get :index, { }
    end
    assert_response :success
    assert_not_nil assigns(:common_parameters)
    common_parameters = ActiveSupport::JSON.decode(@response.body)
    assert !common_parameters.empty?
  end

  test "should show parameter" do
    as_user :admin do
      get :show, { :id => parameters(:common).to_param }
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create common_parameter" do
    as_user :admin do
      assert_difference('CommonParameter.count') do
        post :create, { :common_parameter => valid_attrs }
      end
    end
    assert_response :success
  end

  test "should update common_parameter" do
    as_user :admin do
      put :update, { :id => parameters(:common).to_param, :common_parameter => { } }
    end
    assert_response :success
  end

  test "should destroy common_parameter" do
    as_user :admin do
      assert_difference('CommonParameter.count', -1) do
        delete :destroy, { :id => parameters(:common).to_param }
      end
    end
    assert_response :success
  end

end
