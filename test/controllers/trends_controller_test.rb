require 'test_helper'

class TrendsControllerTest < ActionController::TestCase
  basic_pagination_rendered_test
  basic_pagination_per_page_test

  test "should get empty_data page, if no trend counters exist" do
    trend = FactoryGirl.create(:trend_os)
    get :show, { :id => trend.id }, set_session_user
    assert_response :success
    assert_template :partial => 'trends/_empty_data'
  end

  test "should show Foreman model trend" do
    trend = FactoryGirl.create(:trend_os, :with_values, :with_counters)
    get :show, { :id => trend.id }, set_session_user
    assert_response :success
    assert_template 'show'
  end

  test "should show Foreman model trend value details" do
    trend = FactoryGirl.create(:trend_os, :with_values, :with_counters)
    trend_value = trend.values.find { |t| t.trend_counters.any? }
    get :show, { :id => trend_value.id }, set_session_user
    assert_response :success
    assert_template 'show'
  end

  test "should show fact trend" do
    trend = FactoryGirl.create(:fact_trend, :with_values, :with_counters)
    get :show, { :id => trend.id }, set_session_user
    assert_response :success
    assert_template 'show'
  end

  test "should show fact trend value details" do
    trend = FactoryGirl.create(:fact_trend, :with_values, :with_counters)
    trend_value = trend.values.find { |t| t.trend_counters.any? }
    get :show, { :id => trend_value.id }, set_session_user
    assert_response :success
    assert_template 'show'
  end

  test 'should create trend' do
    trend_parameters = { :name => 'test', :fact_name => 'os',
                         :fact_value => 'fedora', :trendable_type => 'FactName'}
    post :create, { :trend => trend_parameters }, set_session_user
    assert_response :success
  end

  test 'should update trend' do
    put :edit, { :id => FactoryGirl.create(:trend_os).id, :trend => { :name => 'test2'} },
      set_session_user
    assert_response :success
  end
end
