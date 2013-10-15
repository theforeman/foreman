FactoryGirl.define do
  factory :usergroup do
    sequence(:name) {|n| "usergroup#{n}" }
  end
end
