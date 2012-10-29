require 'test_helper'

class Api::V1::FactValuesControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:fact_values)
    fact_values = ActiveSupport::JSON.decode(@response.body)
    assert !fact_values.empty?
  end
end
