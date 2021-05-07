FactoryBot.define do
  factory :medium do
    sequence(:name) { |n| "medium#{n}" }
    sequence(:path) { |n| "http://www.example.com/path#{n}" }
    os_family { 'Redhat' }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    factory :centos_for_snapshots do
      name { |n| "CentOS Mirror" }
      path { 'http://mirror.centos.org/centos/$major/os/x86_64' }
    end

    trait :centos do
      sequence(:name) { |n| "CentOS Mirror #{n}" }
      sequence(:path) { 'http://mirror.centos.org/centos/$major/os/x86_64' }
    end

    trait :coreos do
      sequence(:name) { |n| "CoreOS Mirror #{n}" }
      sequence(:path) { 'http://$release.release.core-os.net' }
      os_family { 'Coreos' }
    end

    trait :flatcar do
      sequence(:name) { |n| "Flatcar Mirror #{n}" }
      sequence(:path) { 'http://$release.release.flatcar-linux.net' }
      os_family { 'Coreos' }
    end

    trait :ubuntu do
      sequence(:name) { |n| "Ubuntu Mirror #{n}" }
      sequence(:path) { 'http://archive.ubuntu.com/ubuntu' }
      os_family { 'Debian' }
    end

    trait :debian do
      sequence(:name) { |n| "Debian Mirror #{n}" }
      sequence(:path) { 'http://ftp.debian.org/debian' }
      os_family { 'Debian' }
    end

    trait :suse do
      sequence(:name) { |n| "OpenSuse Mirror #{n}" }
      sequence(:path) { 'http://mirror.isoc.org.il/pub/opensuse/distribution/$major.$minor/repo/oss' }
      os_family { 'Suse' }
    end

    trait :rancheros do
      sequence(:name) { |n| "Rancheros Mirror #{n}" }
      sequence(:path) { 'https://github.com/rancher/os/releases/download/v$version' }
      os_family { 'Rancheros' }
    end

    trait :altlinux do
      sequence(:name) { |n| "Altlinux Mirror #{n}" }
      sequence(:path) { 'http://example.com/pub/altlinux/$version' }
      os_family { 'Altlinux' }
    end

    trait :solaris do
      sequence(:name) { |n| "Solaris Mirror #{n}" }
      path { 'http://www.example.com/vol/solgi_5.10/sol$minor_$release_$arch' }
      media_path { 'www.example.com:/vol/solgi_5.10/sol$minor_$release_$arch' }
      config_path { 'www.example.com:/vol/jumpstart' }
      image_path { 'www.example.com:/vol/solgi_5.10/sol$minor_$release_$arch/flash/' }
      os_family { 'Solaris' }
    end

    trait :freebsd do
      sequence(:name) { |n| "Freebsd Mirror #{n}" }
      sequence(:path) { 'http://ftp.freebsd.org/pub/FreeBSD/releases/$arch/$major.$minor-RELEASE' }
      os_family { 'Freebsd' }
    end

    trait :with_operatingsystem do
      operatingsystems { [FactoryBot.create(:operatingsystem, :with_archs)] }
    end
  end
end
