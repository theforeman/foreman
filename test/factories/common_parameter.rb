FactoryBot.define do
  factory :common_parameter do
    sequence(:name) { |n| "parameter-#{n}" }
  end
end
