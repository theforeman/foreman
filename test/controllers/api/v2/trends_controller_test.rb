require 'test_helper'

class Api::V2::TrendsControllerTest < ActionController::TestCase
  def setup
    @foreman_trend_valid_attrs = { :trendable_type => 'Model' }
    @foreman_trend_invalid_attrs = { :trendable_type => 'NotExists' }

    @foreman_trend = FactoryBot.create(:foreman_trend, :trendable_type => 'Environment', :fact_name => "fact")
    @host = FactoryBot.create(:host)
    FactoryBot.create(:fact_value, :value => '2.6.9', :host => @host,
                      :fact_name => FactoryBot.create(:fact_name, :name => 'kernelversion'))
    @fact_os = FactoryBot.create(:fact_value, :value => 'fedora', :host => @host,
                      :fact_name => FactoryBot.create(:fact_name, :name => 'operatingsystem'))
    @fact_trend = FactoryBot.create(:fact_trend, :trendable_type => 'FactName')
    @fact_trend_valid_attrs = { :trendable_type => 'FactName', :trendable_id => @fact_os.fact_name_id.to_s }
  end

  test "should get index" do
    get :index, params: {}
    assert_response :success
    assert_not_nil assigns(:trends)
    trends = ActiveSupport::JSON.decode(@response.body)
    assert_equal [@foreman_trend.fact_name, @fact_trend.fact_name].sort, trends['results'].map { |t| t['fact_name'] }.sort
  end

  test "should create a valid foreman trend" do
    assert_difference('Trend.types.where(:type => "ForemanTrend").count', 1) do
      post :create, params: { :trend => @foreman_trend_valid_attrs}
      result = ActiveSupport::JSON.decode(@response.body)
      assert_equal("Model", result["trendable_type"])
      assert_equal("ForemanTrend", result["type"])
    end
    assert_response :created
  end

  test "should create a valid fact trend" do
    assert_difference('Trend.types.where(:type => "FactTrend").count', 1) do
      post :create, params: { :trend => @fact_trend_valid_attrs }
      result = ActiveSupport::JSON.decode(@response.body)
      assert_equal("FactName", result["trendable_type"])
      assert_equal("operatingsystem", result["fact_name"])
      assert_equal("FactTrend", result["type"])
    end
    assert_response :created
  end

  test "should not create invalid trends" do
    assert_no_difference('Trend.types.count') do
      post :create, params: { :trend => @foreman_trend_invalid_attrs }
    end
    assert_response :error
  end

  test "should show individual record" do
    get :show, params: { :id => @foreman_trend.id.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal @foreman_trend.trendable_type, show_response['trendable_type']
  end

  test "should destroy trends " do
    assert_difference('Trend.types.count', -2) do
      delete :destroy, params: { :id => @foreman_trend.id.to_param }
      delete :destroy, params: { :id => @fact_trend.id.to_param }
    end
    assert_response :success
  end
end
