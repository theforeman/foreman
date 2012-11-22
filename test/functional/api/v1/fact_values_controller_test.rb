require 'test_helper'

class Api::V1::FactValuesControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, { }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    assert !fact_values.empty?
  end

end
