FactoryGirl.define do
  factory :smart_proxy do
    sequence(:name) {|n| "proxy#{n}" }
    sequence(:url) {|n| "https://somewhere#{n}.net:8443" }
    factory :template_smart_proxy do
      ProxyAPI::Features.any_instance.stubs(:features).returns(['templates',
                                                                'tftp'])
      features { |sp| [sp.association(:template_feature), sp.association(:tftp_feature) ] }
    end

    factory :dhcp_smart_proxy do
      ProxyAPI::Features.any_instance.stubs(:features).returns(['dhcp'])
      features { |sp| [sp.association(:feature, :dhcp)] }
    end

    factory :dns_smart_proxy do
      ProxyAPI::Features.any_instance.stubs(:features).returns(['dns'])
      features { |sp| [sp.association(:feature, :dns)] }
    end

    factory :puppet_smart_proxy do
      ProxyAPI::Features.any_instance.stubs(:features).returns(['puppet'])
      features { |sp| [sp.association(:feature, :puppet)] }
    end

    factory :puppet_ca_smart_proxy do
      ProxyAPI::Features.any_instance.stubs(:features).returns(['puppetca'])
      features { |sp| [sp.association(:feature, :puppetca)] }
    end

    factory :puppet_and_ca_smart_proxy do
      ProxyAPI::Features.any_instance.stubs(:features).returns(['puppet',
                                                                'puppetca'])
      features { |sp| [sp.association(:feature, :puppet), sp.association(:feature, :puppetca) ] }
    end

    factory :realm_smart_proxy do
      ProxyAPI::Features.any_instance.stubs(:features).returns(['realm'])
      features { |sp| [sp.association(:feature, :realm)] }
    end
  end
end
