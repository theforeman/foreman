FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| "org#{n}" }

    trait :with_parameter do
      after(:create) do |organization,evaluator|
        FactoryGirl.create(:lookup_value, :with_key, :match => organization.lookup_value_matcher)
      end
    end
  end

  factory :location do
    sequence(:name) { |n| "loc#{n}" }

    trait :with_parameter do
      after(:create) do |location,evaluator|
        FactoryGirl.create(:lookup_value, :with_key, :match => location.lookup_value_matcher)
      end
    end
  end
end
