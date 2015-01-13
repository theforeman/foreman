FactoryGirl.define do
  factory :medium do
    sequence(:name) {|n| "medium#{n}" }
    sequence(:path) {|n| "http://www.example.com/path#{n}" }

    trait :coreos do
      sequence(:name) {'CoreOS Mirror'}
      sequence(:path) {'http://$release.release.core-os.net'}
    end

    trait :ubuntu do
      sequence(:name) {'Ubuntu Mirror'}
      sequence(:path) {'http://archive.ubuntu.com/ubuntu'}
    end

    trait :debian do
      sequence(:name) {'Debian Mirror'}
      sequence(:path) {'http://ftp.debian.org/debian'}
    end

    trait :suse do
      sequence(:name) {'OpenSuse Mirror'}
      sequence(:path) {'http://mirror.isoc.org.il/pub/opensuse/distribution/$major.$minor/repo/oss'}
    end
  end
end
