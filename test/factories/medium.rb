FactoryBot.define do
  factory :medium do
    sequence(:name) {|n| "medium#{n}" }
    sequence(:path) {|n| "http://www.example.com/path#{n}" }
    os_family { 'Redhat' }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    trait :coreos do
      sequence(:name) { |n| "CoreOS Mirror #{n}"}
      sequence(:path) {'http://$release.release.core-os.net'}
      os_family { 'Coreos' }
    end

    trait :ubuntu do
      sequence(:name) { |n| "Ubuntu Mirror #{n}"}
      sequence(:path) {'http://archive.ubuntu.com/ubuntu'}
      os_family { 'Debian' }
    end

    trait :debian do
      sequence(:name) { |n| "Debian Mirror #{n}"}
      sequence(:path) {'http://ftp.debian.org/debian'}
      os_family { 'Debian' }
    end

    trait :suse do
      sequence(:name) { |n| "OpenSuse Mirror #{n}"}
      sequence(:path) {'http://mirror.isoc.org.il/pub/opensuse/distribution/$major.$minor/repo/oss'}
      os_family { 'Suse' }
    end

    trait :rancheros do
      sequence(:name) { |n| "Rancheros Mirror #{n}"}
      sequence(:path) { 'https://github.com/rancher/os/releases/download/v$version' }
      os_family { 'Rancheros' }
    end

    trait :with_operatingsystem do
      operatingsystems { [FactoryBot.create(:operatingsystem, :with_archs)] }
    end
  end
end
