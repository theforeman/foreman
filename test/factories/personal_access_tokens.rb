FactoryBot.define do
  factory :personal_access_token do
    sequence(:name) { |n| "Personal Access Token #{n}" }
    revoked { false }
    sequence(:token) do |n|
      hasher = Foreman::PasswordHash.new
      hasher.hash_secret('OSKoHLYqOj0AQd5dnyb8sw', hasher.calculate_salt(n, 5))
    end
    expires_at { 10.days.from_now }
    association :user, :factory => :user
  end
end
