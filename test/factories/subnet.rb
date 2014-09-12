FactoryGirl.define do
  factory :subnet do
    sequence(:name) {|n| "subnet#{n}" }
    sequence(:network) {|n| "10.0.#{n}.0" }
    mask "255.255.255.0"
    association :dhcp, :factory => :smart_proxy
    association :dns, :factory => :smart_proxy
  end
end
