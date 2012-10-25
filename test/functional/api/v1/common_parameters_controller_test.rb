require 'test_helper'

class Api::V1::CommonParametersControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:common_parameters)
    common_parameters = ActiveSupport::JSON.decode(@response.body)
    assert !common_parameters.empty?
  end

  test "should show compute_resource" do
    as_user :admin do
      get :show, {:id => parameters(:common).to_param}
    end
    assert_response :success
  end

end
