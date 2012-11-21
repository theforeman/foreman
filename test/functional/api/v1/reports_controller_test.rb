require 'test_helper'

class Api::V1::ReportsControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, { }
    end
    assert_response :success
    assert_not_nil assigns(:reports)
    reports = ActiveSupport::JSON.decode(@response.body)
    assert !reports.empty?
  end

  test "should show individual record" do
    as_user :admin do
      get :show, { :id => reports(:report).to_param }
    end
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should destroy report" do
    as_user :admin do
      assert_difference('Report.count', -1) do
        delete :destroy, { :id => reports(:report).to_param }
      end
    end
    assert_response :success
  end


end
