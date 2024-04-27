FactoryBot.define do
  proxy_features = [
    :bmc,
    :dhcp,
    :dns,
    :external_ipam,
    :httpboot,
    :puppetca,
    :realm,
    :templates,
    :tftp,
  ]

  factory :smart_proxy do
    sequence(:name) { |n| "proxy#{n}" }
    sequence(:url) { |n| "https://somewhere#{n}.net:8443" }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    transient do
      skip_associate_features { true }
    end

    initialize_with do
      obj = new
      obj.skip_associate_features = skip_associate_features
      obj
    end

    trait :ignore_validations do
      callback(:after_stub, :after_build) do |proxy|
        proxy.define_singleton_method(:valid?) { |*_args| true }
      end
    end

    proxy_features.each do |feature|
      trait feature do
        smart_proxy_features do
          [association(:smart_proxy_feature, feature, :smart_proxy => @instance)]
        end
      end
    end
  end

  factory :smart_proxy_feature do
    proxy_features.each do |feature|
      trait feature do
        association :feature, feature
      end
    end
  end
end
