FactoryBot.define do
  factory :smart_proxy do
    sequence(:name) {|n| "proxy#{n}" }
    sequence(:url) {|n| "https://somewhere#{n}.net:8443" }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    before(:create, :build, :build_stubbed) do
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns(Hash[Feature.name_map.keys.collect {|f| [f, {'state' => 'running'}]}])
    end

    after(:create) do |proxy|
      proxy.reload unless proxy.new_record?
    end

    factory :template_smart_proxy do
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :templates, :smart_proxy => smart_proxy)
      end
    end

    factory :bmc_smart_proxy do
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :bmc, :smart_proxy => smart_proxy)
      end
    end

    factory :dhcp_smart_proxy do
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :dhcp, :smart_proxy => smart_proxy)
      end
    end

    factory :dns_smart_proxy do
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :dns, :smart_proxy => smart_proxy)
      end
    end

    factory :puppet_smart_proxy do
      before(:create, :build, :build_stubbed) do
        ProxyAPI::V2::Features.any_instance.stubs(:features).returns(:puppet => {'state' => 'running'})
      end
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :puppet, :smart_proxy => smart_proxy)
      end
    end

    factory :puppet_ca_smart_proxy do
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :puppetca, :smart_proxy => smart_proxy)
      end
    end

    factory :puppet_and_ca_smart_proxy do
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :puppet, :smart_proxy => smart_proxy)
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :puppetca, :smart_proxy => smart_proxy)
      end
    end

    factory :realm_smart_proxy do
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :realm, :smart_proxy => smart_proxy)
      end
    end
  end

  factory :smart_proxy_feature do
    trait :templates do
      association :feature, :templates
    end

    trait :tftp do
      association :feature, :tftp
    end

    trait :dhcp do
      association :feature, :dhcp
    end

    trait :dns do
      association :feature, :dns
    end

    trait :realm do
      association :feature, :realm
    end

    trait :puppetca do
      association :feature, :puppetca
    end

    trait :puppet do
      association :feature, :puppet
    end

    trait :bmc do
      association :feature, :bmc
    end
  end
end
