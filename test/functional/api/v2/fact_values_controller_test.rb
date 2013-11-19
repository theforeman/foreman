require 'test_helper'

class Api::V2::FactValuesControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, { }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    assert !fact_values.empty?
  end

  test "should get facts for given system only" do
    get :index, {:system_id => systems(:one).to_param }
    assert_response :success
    fact_values = ActiveSupport::JSON.decode(@response.body)
    assert !fact_values.empty?
  end

end
