FactoryBot.define do
  factory :ssh_key do
    sequence(:name) { |n| "user#{n}@example.com" }
    sequence(:key) do |n|
      [SSHKey.generate.ssh_public_key, "foreman#{n}@example.com"].join(' ')
    end
    association :user, :factory => :user
  end
end
