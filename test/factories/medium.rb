FactoryBot.define do
  factory :medium do
    sequence(:name) {|n| "medium#{n}" }
    sequence(:path) {|n| "http://www.example.com/path#{n}" }

    trait :coreos do
      sequence(:name) { |n| "CoreOS Mirror #{n}"}
      sequence(:path) {'http://$release.release.core-os.net'}
    end

    trait :ubuntu do
      sequence(:name) { |n| "Ubuntu Mirror #{n}"}
      sequence(:path) {'http://archive.ubuntu.com/ubuntu'}
    end

    trait :debian do
      sequence(:name) { |n| "Debian Mirror #{n}"}
      sequence(:path) {'http://ftp.debian.org/debian'}
    end

    trait :suse do
      sequence(:name) { |n| "OpenSuse Mirror #{n}"}
      sequence(:path) {'http://mirror.isoc.org.il/pub/opensuse/distribution/$major.$minor/repo/oss'}
    end
  end
end
