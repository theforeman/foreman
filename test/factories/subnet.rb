FactoryGirl.define do
  factory :subnet_parameter, :parent => :parameter, :class => SubnetParameter do
    type 'SubnetParameter'
  end

  factory :subnet do
    sequence(:name) {|n| "subnet#{n}" }
    ipam "None"

    trait :tftp do
      association :tftp, :factory => :template_smart_proxy
    end

    trait :dhcp do
      association :dhcp, :factory => :dhcp_smart_proxy
    end

    trait :dns do
      association :dns, :factory => :dns_smart_proxy
    end

    trait :with_domains do
      transient do
        domains_count 2
      end

      after(:create) do |subnet, evaluator|
        FactoryGirl.create_list(:domain, evaluator.domains_count, :subnets => [subnet])
      end
    end

    trait :ipam_db do
      ipam "Internal DB"
    end

    factory :subnet_ipv4, :class => Subnet::Ipv4 do
      network { 3.times.map { rand(256) }.join('.') + '.0' }
      mask { '255.255.255.0' }

      factory :subnet_ipv4_with_domains, :traits => [:with_domains]

      trait :ipam_dhcp do
        ipam "DHCP"
      end

      trait :with_parameter do
        after(:create) do |subnet,evaluator|
          FactoryGirl.create(:subnet_parameter, :subnet => subnet)
        end
      end
    end

    factory :subnet_ipv6, :class => Subnet::Ipv6 do
      network { 4.times.map { '%x' % rand(16**4) }.join(':') + '::' }
      mask { 4.times.map { 'ffff' }.join(':') + '::' }

      factory :subnet_ipv6_with_domains, :traits => [:with_domains]
    end
  end
end
