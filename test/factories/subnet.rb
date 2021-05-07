FactoryBot.define do
  factory :subnet_parameter, :parent => :parameter, :class => SubnetParameter do
    type { 'SubnetParameter' }
  end

  factory :subnet do
    sequence(:name) { |n| "subnet#{n}" }
    ipam { "None" }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }
    boot_mode { :DHCP }

    # Skip the Subnet.after_validation hook that validates against External IPAM API
    after(:build) do |subnet|
      subnet.class.skip_callback(:validation, :after, :validate_against_external_ipam, raise: false)
    end

    trait :tftp do
      association :tftp, :factory => :template_smart_proxy
    end

    trait :httpboot do
      association :httpboot, :factory => :template_smart_proxy
    end

    trait :dhcp do
      association :dhcp, :factory => :dhcp_smart_proxy
    end

    trait :dns do
      association :dns, :factory => :dns_smart_proxy
    end

    trait :bmc do
      association :bmc, :factory => :bmc_smart_proxy
    end

    trait :template do
      association :template, :factory => :template_smart_proxy
    end

    trait :with_domains do
      transient do
        domains_count { 2 }
      end

      after(:create) do |subnet, evaluator|
        FactoryBot.create_list(:domain, evaluator.domains_count, :subnets => [subnet])
      end
    end

    trait :ipam_db do
      ipam { "Internal DB" }
    end

    trait :with_taxonomies do
      locations { [FactoryBot.create(:location)] }
      organizations { [FactoryBot.create(:organization)] }
    end

    factory :subnet_ipv4, :class => Subnet::Ipv4 do
      network { Array.new(3) { rand(256) }.join('.') + '.0' }
      mask { '255.255.255.0' }

      factory :subnet_ipv4_with_domains, :traits => [:with_domains]
      factory :subnet_ipv4_with_bmc, :traits => [:bmc]

      trait :ipam_dhcp do
        ipam { "DHCP" }
      end

      trait :with_parameter do
        after(:create) do |subnet, evaluator|
          FactoryBot.create(:subnet_parameter, :subnet => subnet)
        end
      end
    end

    factory :subnet_ipv6, :class => Subnet::Ipv6 do
      network { Array.new(4) { '%x' % rand(16**4) }.join(':') + '::' }
      mask { Array.new(4, 'ffff').join(':') + '::' }

      factory :subnet_ipv6_with_domains, :traits => [:with_domains]
    end

    trait :proxies_for_snapshots do
      # ability to build more than one smart proxies with the same url or name for snapshot testing
      association :tftp, :ignore_validations, :factory => :template_smart_proxy, :name => "snapshot-proxy-tftp", :url => "http://localhost:8001"
      association :httpboot, :ignore_validations, :factory => :template_smart_proxy, :name => "snapshot-proxy-httpboot", :url => "http://localhost:8002"
      association :dhcp, :ignore_validations, :factory => :dhcp_smart_proxy, :name => "snapshot-proxy-dhcp", :url => "http://localhost:8003"
      association :dns, :ignore_validations, :factory => :dns_smart_proxy, :name => "snapshot-proxy-dns", :url => "http://localhost:8004"
      association :bmc, :ignore_validations, :factory => :bmc_smart_proxy, :name => "snapshot-proxy-bmc", :url => "http://localhost:8005"
    end

    factory :subnet_ipv4_dhcp_for_snapshots, :class => Subnet::Ipv4 do
      network { '192.168.42.0' }
      mask { '255.255.255.0' }
      name { 'snapshot-ipv4-dhcp' }
      gateway { '192.168.42.1' }
      dns_primary { '192.168.42.2' }
      dns_secondary { '192.168.42.3' }
      mtu { '1142' }
      boot_mode { :DHCP }
      domains { [FactoryBot.build(:domain_for_snapshots)] }
      proxies_for_snapshots
    end

    factory :subnet_ipv4_static_for_snapshots, :class => Subnet::Ipv4 do
      network { '192.168.42.0' }
      mask { '255.255.255.0' }
      name { 'snapshot-ipv4-static' }
      gateway { '192.168.42.1' }
      dns_primary { '192.168.42.2' }
      dns_secondary { '192.168.42.3' }
      mtu { '1242' }
      boot_mode { :Static }
      domains { [FactoryBot.build(:domain_for_snapshots)] }
      proxies_for_snapshots
    end

    factory :subnet_ipv6_dhcp_for_snapshots, :class => Subnet::Ipv6 do
      network { '2001:db8:42::' }
      mask { 'ffff:ffff:ffff::' }
      name { 'snapshot-ipv6-dhcp' }
      gateway { '2001:db8:42::1' }
      dns_primary { '2001:db8:42::8' }
      dns_secondary { '2001:db8:42::4' }
      mtu { '1342' }
      boot_mode { :DHCP }
      domains { [FactoryBot.build(:domain_for_snapshots)] }
      proxies_for_snapshots
    end

    factory :subnet_ipv6_static_for_snapshots, :class => Subnet::Ipv6 do
      network { '2001:db8:42::' }
      mask { 'ffff:ffff:ffff::' }
      name { 'snapshot-ipv6-static' }
      gateway { '2001:db8:42::1' }
      dns_primary { '2001:db8:42::8' }
      dns_secondary { '2001:db8:42::4' }
      mtu { '1442' }
      boot_mode { :Static }
      domains { [FactoryBot.build(:domain_for_snapshots)] }
      proxies_for_snapshots
    end
  end
end
