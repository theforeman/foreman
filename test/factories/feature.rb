FactoryGirl.define do
  factory :feature do
    factory :template_feature do
      name 'Templates'
    end

    factory :tftp_feature do
      name 'TFTP'
    end

    trait :tftp do
      name 'tftp'
    end

    trait :dhcp do
      name 'dhcp'
    end

    trait :dns do
      name 'dns'
    end

    trait :realm do
      name 'realm'
    end

    trait :puppetca do
      name 'puppetca'
    end

    trait :puppet do
      name 'puppet'
    end
  end
end
