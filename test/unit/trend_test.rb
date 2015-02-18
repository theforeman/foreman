require 'test_helper'

class TrendTest < ActiveSupport::TestCase
  test "should delete trend and associated trend counters" do
    trend = trends(:one)
    trend_id = trend.id
    assert_equal 2, TrendCounter.where(:trend_id => trend_id).length
    assert_difference('Trend.count', -1) do
      as_admin do
        trend.destroy
      end
    end
    assert_equal 0, TrendCounter.where(:trend_id => trend_id).length
  end
end
