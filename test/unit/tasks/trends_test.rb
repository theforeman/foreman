require 'test_helper'
require 'rake'

class TrendsTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/trends'
    Rake::Task.define_task(:environment)
    Rake::Task['trends:reduce'].reenable

    TrendCounter.unscoped.delete_all
    Trend.unscoped.delete_all
  end

  test 'trends:reduce reduces single trend' do
    trend = FactoryBot.build(:trend_os)
    point_dates = create_trend_line(trend, [1, 1, 1, 1, 1, 1])

    Rake.application.invoke_task 'trends:reduce'

    trend_counter = TrendCounter.where(trend_id: trend.id)

    assert_equal 1, trend_counter.count

    trend_counter = trend_counter.first

    assert_equal point_dates.min.to_i, trend_counter.interval_start.to_i
    assert_nil trend_counter.interval_end
  end

  test 'trends:reduce does not iterfere between two trend ids' do
    trend1 = FactoryBot.build(:trend_os)
    trend2 = FactoryBot.build(:trend_os)
    create_trend_line(trend1, [1, 1, 1, 1, 1, 1])
    create_trend_line(trend2, [2, 2, 2, 2, 2, 2])

    Rake.application.invoke_task 'trends:reduce'

    trend_10 = TrendCounter.where(trend_id: trend1.id)
    trend_20 = TrendCounter.where(trend_id: trend2.id)

    assert_equal 1, trend_10.count
    assert_equal 1, trend_20.count

    trend_10 = trend_10.first
    trend_20 = trend_20.first

    assert_equal trend_10.interval_start, trend_20.interval_start
    assert_nil trend_10.interval_end
    assert_nil trend_20.interval_end
  end

  test 'trends:reduce crossing graphs' do
    new_os_trend = FactoryBot.build(:trend_os)
    old_os_trend = FactoryBot.build(:trend_os)
    new_os_point_dates = create_trend_line(new_os_trend, [1, 1, 1, 2, 2, 2, 3, 3, 3])
    create_trend_line(old_os_trend, [3, 3, 3, 2, 2, 2, 1, 1, 1])
    interval_starts = [new_os_point_dates[0], new_os_point_dates[3], new_os_point_dates[6]]

    Rake.application.invoke_task 'trends:reduce'

    new_os_intervals = TrendCounter.where(trend_id: new_os_trend.id).order(:interval_start).to_a
    old_os_intervals = TrendCounter.where(trend_id: old_os_trend.id).order(:interval_start).to_a

    assert_equal 3, new_os_intervals.length
    assert_equal 3, old_os_intervals.length

    interval_starts.each_with_index do |start, idx|
      assert_equal start, old_os_intervals[idx].interval_start
      assert_equal start, new_os_intervals[idx].interval_start

      if idx < 2
        next_start = interval_starts[idx + 1]
        refute_nil next_start
        assert_equal next_start, old_os_intervals[idx].interval_end
        assert_equal next_start, new_os_intervals[idx].interval_end
      else
        assert_nil old_os_intervals[idx].interval_end
        assert_nil new_os_intervals[idx].interval_end
      end

      assert_equal 4, old_os_intervals[idx].count + new_os_intervals[idx].count
    end
  end

  test 'trends:reduce mirrored saw graphs' do
    new_os_trend = FactoryBot.build(:trend_os)
    old_os_trend = FactoryBot.build(:trend_os)
    new_os_point_dates = create_trend_line(new_os_trend, [1, 1, 1, 2, 2, 2, 1, 1, 1, 2, 2, 2])
    create_trend_line(old_os_trend, [3, 3, 3, 2, 2, 2, 3, 3, 3, 2, 2, 2])
    interval_starts = [new_os_point_dates[0], new_os_point_dates[3], new_os_point_dates[6], new_os_point_dates[9]]
    new_os_counts = [1, 2, 1, 2]

    Rake.application.invoke_task 'trends:reduce'

    new_os_intervals = TrendCounter.where(trend_id: new_os_trend.id).order(:interval_start).to_a
    old_os_intervals = TrendCounter.where(trend_id: old_os_trend.id).order(:interval_start).to_a

    assert_equal 4, new_os_intervals.length
    assert_equal 4, old_os_intervals.length

    interval_starts.each_with_index do |start, idx|
      assert_equal start, old_os_intervals[idx].interval_start
      assert_equal start, new_os_intervals[idx].interval_start

      if idx < 3
        next_start = interval_starts[idx + 1]
        refute_nil next_start
        assert_equal next_start, old_os_intervals[idx].interval_end
        assert_equal next_start, new_os_intervals[idx].interval_end
      else
        assert_nil old_os_intervals[idx].interval_end
        assert_nil new_os_intervals[idx].interval_end
      end

      assert_equal 4, old_os_intervals[idx].count + new_os_intervals[idx].count
      assert_equal new_os_counts[idx], new_os_intervals[idx].count
    end
  end

  test 'trends:reduce can rerun with additional datapoint with the same value' do
    os_trend = FactoryBot.build(:trend_os)
    os_point_dates = create_trend_line(os_trend, [1, 1, 1, 1, 1, 1])
    Rake.application.invoke_task 'trends:reduce'

    interval = TrendCounter.where(trend_id: os_trend.id).order(:interval_start).to_a
    assert_equal 1, interval.length
    interval = interval.first

    FactoryBot.build(:trend_counter, :trend => os_trend, :created_at => os_point_dates[3], :updated_at => os_point_dates[3], :count => 1)

    Rake::Task['trends:reduce'].reenable
    Rake.application.invoke_task 'trends:reduce'

    new_interval = TrendCounter.where(trend_id: os_trend.id).order(:interval_start).to_a
    assert_equal 1, new_interval.length
    new_interval = new_interval.first

    assert_equal new_interval, interval
  end

  test 'trends:reduce can rerun with additional datapoint with different value in open interval' do
    os_trend = FactoryBot.build(:trend_os)
    os_point_dates = create_trend_line(os_trend, [1, 1, 1, 1, 1, 1])
    Rake.application.invoke_task 'trends:reduce'

    interval = TrendCounter.where(trend_id: os_trend.id).order(:interval_start).to_a
    assert_equal 1, interval.length

    FactoryBot.create(:trend_counter, :trend => os_trend, :created_at => os_point_dates[3], :updated_at => os_point_dates[3], :count => 2)

    Rake::Task['trends:reduce'].reenable
    Rake.application.invoke_task 'trends:reduce'

    new_intervals = TrendCounter.where(trend_id: os_trend.id).order(:interval_start).to_a
    assert_equal 2, new_intervals.length

    assert_equal 1, new_intervals[0].count
    assert_equal 2, new_intervals[1].count

    assert_equal os_point_dates[0], new_intervals[0].interval_start
    assert_equal os_point_dates[3], new_intervals[0].interval_end
    assert_equal os_point_dates[3], new_intervals[1].interval_start
  end

  test 'trends:reduce can rerun with additional datapoint with different value in closed interval' do
    os_trend = FactoryBot.build(:trend_os)
    os_point_dates = create_trend_line(os_trend, [1, 1, 1, 1, 1, 2])
    Rake.application.invoke_task 'trends:reduce'

    interval = TrendCounter.where(trend_id: os_trend.id).order(:interval_start).to_a
    assert_equal 2, interval.length

    FactoryBot.create(:trend_counter, :trend => os_trend, :created_at => os_point_dates[3], :updated_at => os_point_dates[3], :count => 3)

    Rake::Task['trends:reduce'].reenable
    Rake.application.invoke_task 'trends:reduce'

    new_intervals = TrendCounter.where(trend_id: os_trend.id).order(:interval_start).to_a
    assert_equal 3, new_intervals.length

    assert_equal 1, new_intervals[0].count
    assert_equal 3, new_intervals[1].count
    assert_equal 2, new_intervals[2].count

    assert_equal os_point_dates[0], new_intervals[0].interval_start
    assert_equal os_point_dates[3], new_intervals[0].interval_end
    assert_equal os_point_dates[3], new_intervals[1].interval_start
    assert_equal os_point_dates[5], new_intervals[1].interval_end
    assert_equal os_point_dates[5], new_intervals[2].interval_start
  end

  private

  def create_trend_line(trend, values_line)
    point_dates = []
    point_date = Time.now.utc.beginning_of_day
    values_line.each do |value|
      point_dates << point_date
      FactoryBot.create(:trend_counter, :trend => trend, :created_at => point_date, :updated_at => point_date, :count => value)
      point_date += 10.minutes
    end

    point_dates
  end
end
