require 'test_helper'

class Api::V1::ReportsControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports.empty?
  end
end
