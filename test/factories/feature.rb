FactoryBot.define do
  factory :feature do
    initialize_with { Feature.find_or_create_by(name: name) }

    factory :templates do
      name { 'Templates' }
    end

    factory :tftp_feature do
      name { 'TFTP' }
    end

    trait :tftp do
      name { 'tftp' }
    end

    trait :templates do
      name { 'Templates' }
    end

    trait :dhcp do
      name { 'DHCP' }
    end

    trait :dns do
      name { 'DNS' }
    end

    trait :realm do
      name { 'Realm' }
    end

    trait :puppetca do
      name { 'Puppet CA' }
    end

    trait :bmc do
      name { 'BMC' }
    end

    trait :httpboot do
      name { 'HTTPBoot' }
    end

    trait :external_ipam do
      name { 'External IPAM' }
    end
  end
end
