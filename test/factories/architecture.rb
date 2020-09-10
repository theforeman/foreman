FactoryBot.define do
  factory :architecture do
    sequence(:name) { |n| "x86_64-#{n}" }
  end
end
