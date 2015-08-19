require 'test_helper'

class TrendsControllerTest < ActionController::TestCase
  test "should get empty_data page, if no trend counters exist" do
    trend = FactoryGirl.create(:foreman_trends, :trendable_type => 'FactTrend')
    get :show, { :id => trend.id }, set_session_user
    assert_response :success
    assert_template :partial => 'trends/_empty_data'
  end
end
