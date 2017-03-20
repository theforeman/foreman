require 'test_helper'

class TrendsControllerTest < ActionController::TestCase
  basic_pagination_rendered_test
  basic_pagination_per_page_test

  test "should get empty_data page, if no trend counters exist" do
    trend = FactoryBot.create(:trend_os)
    get :show, params: { :id => trend.id }, session: set_session_user
    assert_response :success
    assert_template :partial => 'trends/_empty_data'
  end

  test "should show Foreman model trend" do
    trend = FactoryBot.create(:trend_os, :with_values, :with_counters)
    get :show, params: { :id => trend.id }, session: set_session_user
    assert_response :success
    assert_template 'show'
  end

  test "should show Foreman model trend value details" do
    trend = FactoryBot.create(:trend_os, :with_values, :with_counters)
    trend_value = trend.values.find { |t| t.trend_counters.any? }
    get :show, params: { :id => trend_value.id }, session: set_session_user
    assert_response :success
    assert_template 'show'
  end

  test "should show fact trend" do
    trend = FactoryBot.create(:fact_trend, :with_values, :with_counters)
    get :show, params: { :id => trend.id }, session: set_session_user
    assert_response :success
    assert_template 'show'
  end

  test "should show fact trend value details" do
    trend = FactoryBot.create(:fact_trend, :with_values, :with_counters)
    trend_value = trend.values.find { |t| t.trend_counters.any? }
    get :show, params: { :id => trend_value.id }, session: set_session_user
    assert_response :success
    assert_template 'show'
  end

  test 'should create trend' do
    trend_parameters = { :name => 'test', :fact_name => 'os',
                         :fact_value => 'fedora', :trendable_type => 'FactName'}
    post :create, params: { :trend => trend_parameters }, session: set_session_user
    assert_response :success
  end

  test 'should update trend' do
    put :edit, params: { :id => FactoryBot.create(:trend_os).id, :trend => { :name => 'test2'} },
      session: set_session_user
    assert_response :success
  end
end
