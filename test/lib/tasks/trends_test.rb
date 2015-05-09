require 'test_helper'
require 'rake'

class TrendsTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/trends'
    Rake::Task.define_task(:environment)
    Rake::Task['trends:clean'].reenable

    TrendCounter.unscoped.delete_all
    Trend.unscoped.delete_all
  end

  test 'trends:clean' do
    trend = FactoryGirl.create(:foreman_trends, :operating_system)
    created_at = Time.now
    args = [:trend_counter, :trend => trend, :created_at => created_at, :updated_at => created_at, :count => 1]
    # create a legit counter
    FactoryGirl.create(*args)

    # now create some dupes (skipping validations)
    2.times do
      FactoryGirl.build(*args).save(validate: false)
    end

    assert_equal 3, TrendCounter.where(trend_id: trend.id).length

    Rake.application.invoke_task 'trends:clean'

    assert_equal 1, TrendCounter.where(trend_id: trend.id).length
  end
end
