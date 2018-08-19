FactoryBot.define do
  factory :feature do
    factory :templates do
      name { 'Templates' }
    end

    factory :tftp_feature do
      name { 'TFTP' }
    end

    trait :tftp do
      name { 'tftp' }
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

    trait :puppet do
      name { 'Puppet' }
    end

    trait :bmc do
      name { 'BMC' }
    end
  end
end
