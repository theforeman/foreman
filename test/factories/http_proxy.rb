FactoryBot.define do
  factory :http_proxy, :class => ::HttpProxy do
    name { 'http_proxies' }
    sequence(:url) { |n| "http://url_#{n}" }
  end
end
