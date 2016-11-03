FactoryGirl.define do
  factory :domain do
    sequence(:name) {|n| "example#{n}.com" }
    fullname { |n| n.name }

    trait :with_parameter do
      after(:create) do |domain,evaluator|
        FactoryGirl.create(:lookup_value, :with_key, :match => domain.lookup_value_matcher)
      end
    end
  end
end
