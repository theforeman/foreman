FactoryGirl.define do
  factory :subnet do
    sequence(:name) {|n| "subnet#{n}" }
    sequence(:network) {|n| "10.0.#{n}.0" }
    mask "255.255.255.0"

    association :dhcp, :factory => :smart_proxy
    association :dns, :factory => :smart_proxy

    trait :tftp do
      association :tftp, :factory => :template_smart_proxy
    end

    trait :dhcp do
      association :dhcp, :factory => :smart_proxy
    end

    trait :dns do
      association :dns, :factory => :smart_proxy
    end

    trait :tftp do
      association :tftp, :factory => :smart_proxy
    end

    trait :ipam_db do
      ipam "Internal DB"
    end
  end
end
