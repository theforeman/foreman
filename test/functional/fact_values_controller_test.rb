require 'test_helper'

class FactValuesControllerTest < ActionController::TestCase
  test "should get list" do
    get :list
    assert_response :success
    assert_not_nil :records
  end

  test "should get list_filter" do
    get :list_filter
    assert_response :found
  end
end
