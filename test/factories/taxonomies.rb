FactoryGirl.define do
  factory :organization do
    sequence(:name) { |n| "org#{n}" }
  end

  factory :location do
    sequence(:name) { |n| "loc#{n}" }
  end
end
