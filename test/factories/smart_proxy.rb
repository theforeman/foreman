FactoryGirl.define do
  factory :smart_proxy do
    sequence(:name) {|n| "proxy#{n}" }
    sequence(:url) {|n| "https://somewhere#{n}.net:8443" }
    factory :template_smart_proxy do
      features { |sp| [sp.association(:template_feature), sp.association(:tftp_feature) ] }
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
