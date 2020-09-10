FactoryBot.define do
  factory :http_proxy, :class => ::HttpProxy do
    sequence(:name) { |n| "http_proxy_#{n}" }
    sequence(:url) { |n| "http://url_#{n}" }
  end
end
