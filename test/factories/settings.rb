FactoryBot.define do
  factory :setting do
    sequence(:name) { |n| "setting#{n}" }
  end
end
