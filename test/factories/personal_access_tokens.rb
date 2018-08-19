FactoryBot.define do
  factory :personal_access_token do
    sequence(:name) {|n| "Personal Access Token #{n}" }
    token { Digest::SHA1.hexdigest(SecureRandom.urlsafe_base64(nil, false)) }
    revoked { false }
    expires_at { 10.days.from_now }
    association :user, :factory => :user
  end
end
