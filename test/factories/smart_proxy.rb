FactoryBot.define do
  factory :smart_proxy do
    sequence(:name) { |n| "proxy#{n}" }
    sequence(:url) { |n| "https://somewhere#{n}.net:8443" }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    before(:create, :build, :build_stubbed) do
      default_features = {
        "dhcp" => {
          "capabilities" => ["dhcp_filename_hostname", "dhcp_filename_ipv4"],
        },
      }
      result = Hash[Feature.name_map.keys.collect { |f| [f, {'state' => 'running'}.merge(default_features[f] || {})] }]
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns(result)
    end

    after(:create) do |proxy|
      proxy.reload unless proxy.new_record?
    end

    trait :ignore_validations do
      callback(:after_stub, :after_build) do |proxy|
        proxy.define_singleton_method(:valid?) { |*_args| true }
      end
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
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :dhcp, :smart_proxy => smart_proxy, :capabilities => ["dhcp_filename_ipv4"])
      end
    end

    factory :dns_smart_proxy do
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :dns, :smart_proxy => smart_proxy)
      end
    end

    factory :ipam_smart_proxy do
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :external_ipam, :smart_proxy => smart_proxy)
      end
    end

    factory :httpboot_smart_proxy do
      after(:build) do |smart_proxy, _evaluator|
        smart_proxy.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :httpboot, :smart_proxy => smart_proxy)
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
      before(:create, :build, :build_stubbed) do
        ProxyAPI::V2::Features.any_instance.stubs(:features).returns(:puppetca => {'state' => 'running'})
      end
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

    trait :external_ipam do
      association :feature, :external_ipam
    end

    trait :httpboot do
      association :feature, :httpboot
    end
  end
end
