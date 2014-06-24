FactoryGirl.define do
  factory :medium do
    sequence(:name) {|n| "medium#{n}" }
    sequence(:path) {|n| "http://www.example.com/path#{n}" }
  end
end
