FactoryBot.define do
  factory :smart_proxy_pool do
    sequence(:name) {|n| "SmartProxyPool Name #{n}" }
    sequence(:hostname) {|n| "someurl#{n}.net" }

    trait :with_puppet do
      before(:create, :build, :build_stubbed) do
        ProxyAPI::Features.any_instance.stubs(:features => ['puppet', 'puppetca'])
      end

      smart_proxies { [FactoryBot.build(:puppet_and_ca_smart_proxy)] }
    end
  end
end
