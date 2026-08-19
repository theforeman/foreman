FactoryBot.define do
  factory :ssh_key do
    sequence(:name) { |n| "user#{n}@example.com" }
    # Each build shells out to ssh-keygen to create a fresh, unique key pair.
    # This is safe to do for as many keys as the tests need: on modern kernels
    # (Linux >= 5.6) /dev/random no longer blocks once the CRNG has been seeded
    # early at boot, so key generation never stalls waiting for entropy.
    sequence(:key) { |n| Foreman::Provision::SshKey.generate(comment: "foreman#{n}@example.com") }
    association :user, :factory => :user
  end
end
