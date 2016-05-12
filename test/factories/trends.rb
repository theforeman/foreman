FactoryGirl.define do
  factory :trends do
    sequence(:name) {|n| "trend#{n}" }
    sequence(:trendable_id)
  end

  factory :foreman_trends, :class => ForemanTrend, :parent => :trends do
    trait :operating_system do
      trendable_type 'Operatingsystem'
      sequence(:name) {|n| "OS#{n}" }
    end
  end

  factory :trend_counter do
  end
end
