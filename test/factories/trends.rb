FactoryBot.define do
  factory :trend do
    sequence(:name) {|n| "trend#{n}" }
    sequence(:trendable_id)

    trait :value do # trend for one value of a fact
      name { nil }
      sequence(:fact_value) { |n| "value #{n}" }
    end

    transient do
      counter_count { 0 }
    end
    trait :with_counters do
      counter_count { 2 }
    end

    after(:create) do |trend, evaluator|
      if trend.fact_value.present? # only trends for a certain value have counters
        trend.trend_counters = (0...evaluator.counter_count).map { FactoryBot.build(:trend_counter) }
      end
    end
  end

  factory :foreman_trend, :class => ForemanTrend, :parent => :trend do
    transient do
      with_values { false }
    end
    trait :with_values do
      with_values { true }
    end

    factory :trend_os do
      trendable_type { 'Operatingsystem' }
      sequence(:name) {|n| "OS#{n}" }

      before(:create) do |trend, evaluator|
        if evaluator.with_values && trend.name.present?
          FactoryBot.create_list(:operatingsystem, 3).each do |os|
            FactoryBot.create(:trend_os, :value, :trendable_id => os.id, :fact_value => os.to_s, :counter_count => evaluator.counter_count)
          end
        end
      end
    end
  end

  factory :fact_trend, :class => FactTrend, :parent => :trend do
    trendable_type { 'FactName' }
    trendable { FactoryBot.create(:fact_name) }

    trait :with_values do
      before(:create) do |trend, evaluator|
        if trend.name.present?
          FactoryBot.create_list(:fact_value, 3, :fact_name => trend.trendable).each do |fact|
            FactoryBot.create(:fact_trend, :value, :trendable_id => trend.trendable_id, :fact_name => trend.trendable.name, :fact_value => fact.value, :counter_count => evaluator.counter_count)
          end
        end
      end
    end
  end

  factory :trend_counter do
    sequence(:count) { |n| n }
  end
end
