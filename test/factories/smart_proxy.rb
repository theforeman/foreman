FactoryBot.define do
  factory :smart_proxy do
    sequence(:name) {|n| "proxy#{n}" }
    sequence(:url) {|n| "https://somewhere#{n}.net:8443" }
    organizations { [Organization.find_by_name('Organization 1')] } if SETTINGS[:organizations_enabled]
    locations { [Location.find_by_name('Location 1')] } if SETTINGS[:locations_enabled]

    before(:create, :build, :build_stubbed) do
      ProxyAPI::Features.any_instance.stubs(:features => Feature.name_map.keys)
    end

    factory :template_smart_proxy do
      features { |sp| [sp.association(:templates)] }
    end

    factory :bmc_smart_proxy do
      features { |sp| [sp.association(:feature, :bmc)] }
    end

    factory :dhcp_smart_proxy do
      features { |sp| [sp.association(:feature, :dhcp)] }
    end

    factory :dns_smart_proxy do
      features { |sp| [sp.association(:feature, :dns)] }
    end

    factory :puppet_smart_proxy do
      before(:create, :build, :build_stubbed) do
        ProxyAPI::Features.any_instance.stubs(:features => ['puppet'])
      end
      features { |sp| [sp.association(:feature, :puppet)] }
    end

    factory :puppet_ca_smart_proxy do
      features { |sp| [sp.association(:feature, :puppetca)] }
    end

    factory :puppet_and_ca_smart_proxy do
      features { |sp| [sp.association(:feature, :puppet), sp.association(:feature, :puppetca) ] }
    end

    factory :realm_smart_proxy do
      features { |sp| [sp.association(:feature, :realm)] }
    end
  end
end
