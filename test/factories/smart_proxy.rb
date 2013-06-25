FactoryGirl.define do
  factory :smart_proxy do
    sequence(:name) {|n| "proxy#{n}" }
    sequence(:url) {|n| "https://somewhere#{n}.net:8443" }
    factory :template_smart_proxy do
      features { |sp| [sp.association(:template_feature), sp.association(:tftp_feature) ] }
    end
  end
end
