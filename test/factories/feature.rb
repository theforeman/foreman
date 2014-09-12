FactoryGirl.define do
  factory :feature do
    trait :dhcp do
      name 'dhcp'
    end

    trait :dns do
      name 'dns'
    end

    trait :puppetca do
      name 'puppetca'
    end

    trait :puppet do
      name 'puppet'
    end
  end
end
