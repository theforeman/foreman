FactoryGirl.define do
  factory :fact_name do
    sequence(:name) {|n| "fact#{n}" }
  end

  factory :fact_value do
    fact_name
    sequence(:value) {|n| "value#{n}" }
    host
  end
end
