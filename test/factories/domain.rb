FactoryGirl.define do
  factory :domain do
    sequence(:name) {|n| "example#{n}.com" }
    fullname { |n| n.name }
  end
end
