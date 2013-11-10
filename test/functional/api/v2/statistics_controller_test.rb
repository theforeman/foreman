require 'test_helper'

class Api::V2::StatisticsControllerTest < ActionController::TestCase


  test "should get statistics" do
    get :index, { }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert !response.empty?
    assert_equal 'statistics', response.keys.first
  end

end
