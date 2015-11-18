require 'test_helper'

class TrendsControllerTest < ActionController::TestCase
  test "should get empty_data page, if no trend counters exist" do
    trend = FactoryGirl.create(:foreman_trends, :trendable_type => 'FactTrend')
    get :show, { :id => trend.id }, set_session_user
    assert_response :success
    assert_template :partial => 'trends/_empty_data'
  end

  test 'should create trend' do
    trend_parameters = { :name => 'test', :fact_name => 'os',
                         :fact_value => 'fedora', :trendable_type => 'FactName'}
    post :create, { :trend => trend_parameters }, set_session_user
    assert_response :success
  end

  test 'should update trend' do
    put :edit, { :id => Trend.last, :trend => { :name => 'test2'} },
      set_session_user
    assert_response :success
  end
end
