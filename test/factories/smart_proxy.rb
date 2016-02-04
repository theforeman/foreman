FactoryGirl.define do
  factory :smart_proxy do
    sequence(:name) {|n| "proxy#{n}" }
    sequence(:url) {|n| "https://somewhere#{n}.net:8443" }

    factory :dhcp_smart_proxy do
      features { |sp| [ sp.association(:feature, :dhcp) ]}
    end

    factory :tftp_smart_proxy do
      features { |sp| [ sp.association(:feature, :tftp) ]}
    end

    factory :dns_smart_proxy do
      features { |sp| [ sp.association(:feature, :dns) ]}
    end

    factory :template_smart_proxy do
      features { |sp| [ sp.association(:feature, :templates), sp.association(:feature, :tftp) ]}
    end

    factory :puppet_smart_proxy do
      features { |sp| [ sp.association(:feature, :puppet), sp.association(:feature, :puppetca) ]}
    end

    factory :logs_smart_proxy do
      features { |sp| [
        sp.association(:feature, :dhcp),
        sp.association(:feature, :dns),
        sp.association(:feature, :puppet),
        sp.association(:feature, :logs),
      ]}
    end
  end
end
