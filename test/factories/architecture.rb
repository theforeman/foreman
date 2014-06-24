FactoryGirl.define do
  factory :architecture do
    sequence(:name) {|n| "arm#{n}" }
  end
end
