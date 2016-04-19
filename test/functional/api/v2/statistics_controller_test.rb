require 'test_helper'

class Api::V2::StatisticsControllerTest < ActionController::TestCase
  test "should get statistics" do
    get :index, { }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_not response.empty?
    expected_keys = ["Architecture Distribution", "Hardware",
                     "Number of CPUs", "env_count", "klass_count",
                     "mem_free", "mem_size", "mem_totfree",
                     "mem_totsize", "os_count", "rubyversion",
                     "swap_free", "swap_size"]

    assert_equal expected_keys, response.keys.sort
  end

  test "should create statistic" do
    assert_difference('Statistic.count') do
      post :create, { :statistic => { :name => 'Uptime', :value => 'uptime_days' } }
    end
    assert_response :created
  end

  test "should destroy statistic" do
    assert_difference('Statistic.count', -1) do
      delete :destroy, { :id => statistics(:rubyversion).to_param }
    end
    assert_response :success
  end
end
