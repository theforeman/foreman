FactoryGirl.define do
  factory :feature do
    trait :dhcp do
      name 'DHCP'
      priority 1000
    end

    trait :dns do
      name 'DNS'
      priority 2000
    end

    trait :tftp do
      name 'TFTP'
      priority 3000
    end

    trait :puppet do
      name 'Puppet'
      priority 4000
    end

    trait :puppetca do
      name 'Puppet CA'
      priority 5000
    end

    trait :facts do
      name 'Facts'
      priority 6000
    end

    trait :realm do
      name 'Realm'
      priority 7000
    end

    trait :bmc do
      name 'BMC'
      priority 8000
    end

    trait :templates do
      name 'Templates'
      priority 9000
    end

    trait :logs do
      name 'Logs'
      priority 10000
    end
  end
end
