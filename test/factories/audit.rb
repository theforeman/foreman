FactoryGirl.define do
  factory :audit do
    sequence(:version) {|n| "#{n}" }
    auditable_type "test"
    action "update"
  end
end
