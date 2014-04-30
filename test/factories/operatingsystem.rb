FactoryGirl.define do
  factory :operatingsystem do
    sequence(:name) { |n| "operatingsystem#{n}" }
    sequence(:major) { |n| n }
  end
end
