FactoryGirl.define do
  factory :hostname do
    sequence(:name) {|n| "Hostname Name #{n}" }
    sequence(:hostname) {|n| "someurl#{n}.net" }
    smart_proxies { |hn| [hn.association(:smart_proxy)] }
  end
end
