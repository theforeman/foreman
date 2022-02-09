FactoryBot.define do
  factory :os_parameter, :parent => :parameter, :class => OsParameter do
    type { 'OsParameter' }
  end

  factory :operatingsystem, class: Operatingsystem do
    sequence(:name) { |n| "operatingsystem#{n}" }
    sequence(:major) { |n| n }

    trait :with_os_defaults do
      after(:create) do |os, evaluator|
        os.provisioning_templates.each do |tmpl|
          FactoryBot.create(:os_default_template,
            :operatingsystem => os,
            :provisioning_template => tmpl,
            :template_kind => tmpl.template_kind)
        end
      end
    end

    trait :with_provision do
      provisioning_templates do
        [FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.find_by_name('provision'))]
      end
      with_os_defaults
    end

    trait :with_pxelinux do
      provisioning_templates do
        [FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.find_by_name('PXELinux'))]
      end
      with_os_defaults
    end

    trait :with_grub do
      provisioning_templates do
        [FactoryBot.create(:provisioning_template, :template_kind => TemplateKind.find_by_name('PXEGrub'))]
      end
      with_os_defaults
    end

    trait :with_archs do
      architectures { [FactoryBot.create(:architecture)] }
    end

    trait :with_media do
      media { [FactoryBot.create(:medium)] }
    end

    trait :with_ptables do
      ptables { [FactoryBot.create(:ptable)] }
    end

    trait :with_associations do
      with_archs
      with_media
      with_ptables
    end

    trait :with_parameter do
      after(:create) do |os, evaluator|
        FactoryBot.create(:os_parameter, :operatingsystem => os)
      end
    end

    factory :coreos, class: Coreos do
      sequence(:name) { 'CoreOS' }
      major { '494' }
      minor { '5.0' }
      type { 'Coreos' }
      release_name { 'stable' }
      title { 'CoreOS 494.5.0' }
    end

    factory :flatcar, class: Coreos do
      sequence(:name) { 'Flatcar' }
      major { '2345' }
      minor { '3.0' }
      type { 'Coreos' }
      release_name { 'stable' }
      title { 'Flatcar 2345.3.0' }
    end

    factory :fcos, class: Fcos do
      sequence(:name) { 'FedoraCoreOS' }
      major { '32' }
      minor { '20200907.3.0' }
      type { 'Fcos' }
      release_name { 'stable' }
      title { 'FedoraCoreOS 32.20200907.3.0' }
    end

    factory :rhcos, class: Rhcos do
      sequence(:name) { 'RedHatCoreOS' }
      major { '4' }
      minor { '5' }
      release_name { '6' }
      type { 'Rhcos' }
      title { 'RedHatCoreOS 4.5.6' }
    end

    factory :ubuntu14_10, class: Debian do
      sequence(:name) { 'Ubuntu' }
      major { '14' }
      minor { '10' }
      type { 'Debian' }
      release_name { 'utopic' }
      title { 'Ubuntu Utopic' }
    end

    factory :debian7_0, class: Debian do
      sequence(:name) { 'Debian' }
      major { '7' }
      minor { '0' }
      type { 'Debian' }
      release_name { 'wheezy' }
      title { 'Debian Wheezy' }
    end

    factory :debian7_1, class: Debian do
      sequence(:name) { 'Debian' }
      major { '7' }
      minor { '1' }
      type { 'Debian' }
      release_name { 'wheezy' }
      title { 'Debian Wheezy' }
    end

    factory :ubuntu18_04, class: Debian do
      sequence(:name) { 'Ubuntu' }
      major { '18' }
      minor { '04' }
      type { 'Debian' }
      release_name { 'bionic' }
      title { 'Ubuntu 18.04' }
    end

    factory :ubuntu20_04, class: Debian do
      sequence(:name) { 'Ubuntu' }
      major { '20' }
      minor { '04' }
      type { 'Debian' }
      release_name { 'focal' }
      title { 'Ubuntu 20.04' }
    end

    factory :ubuntu21_10, class: Debian do
      sequence(:name) { 'Ubuntu' }
      major { '21' }
      minor { '10' }
      type { 'Debian' }
      release_name { 'impish' }
      title { 'Ubuntu 21.10' }
    end

    factory :suse, class: Suse do
      sequence(:name) { 'OpenSuse' }
      major { '11' }
      minor { '4' }
      type { 'Suse' }
      title { 'OpenSuse 11.4' }
    end

    factory :rhel7_5, class: Redhat do
      sequence(:name) { |n| "RedHat#{n}" }
      major { '7' }
      minor { '5' }
      type { 'Redhat' }
      title { 'Red Hat Enterprise Linux 7.5' }
    end

    factory :for_snapshots_centos_7_0, class: Redhat do
      name { 'CentOS' }
      major { '7' }
      minor { '0' }
      type { 'Redhat' }
      title { 'CentOS 7.0' }
      architectures { [FactoryBot.build(:architecture, :for_snapshots_x86_64)] }
      media { [FactoryBot.build(:centos_for_snapshots)] }
      ptables { [FactoryBot.build(:ptable, name: 'ptable')] }
    end

    factory :for_snapshots_debian_10, class: Debian do
      name { 'Debian' }
      major { '10' }
      minor { '0' }
      type { 'Debian' }
      release_name { 'wheezy' }
      title { 'Debian Wheezy' }
      architectures { [FactoryBot.build(:architecture, :for_snapshots_x86_64)] }
      media { [FactoryBot.build(:debian_for_snapshots)] }
      ptables { [FactoryBot.build(:ptable, name: 'ptable')] }
    end

    factory :for_snapshots_ubuntu_20, class: Debian do
      name { 'Ubuntu' }
      major { '20' }
      minor { '04' }
      type { 'Debian' }
      release_name { 'focal' }
      title { 'Ubuntu Focal' }
      architectures { [FactoryBot.build(:architecture, :for_snapshots_x86_64)] }
      media { [FactoryBot.build(:ubuntu_for_snapshots)] }
      ptables { [FactoryBot.build(:ptable, name: 'ptable')] }
    end

    factory :altlinux, class: Altlinux do
      sequence(:name) { 'Altlinux' }
      major { '8' }
      minor { '2' }
      type { 'Altlinux' }
      title { 'Altlinux 8.2' }
    end

    factory :solaris, class: Solaris do
      sequence(:name) { 'Solaris' }
      major { '10' }
      minor { '8' }
      type { 'Solaris' }
      title { 'Solaris 10.8' }
    end

    factory :rancheros, class: Rancheros do
      sequence(:name) { 'Rancheros' }
      major { '1' }
      minor { '4.3' }
      type { 'Rancheros' }
      title { 'Rancheros 1.4.3' }
    end

    factory :freebsd, class: Freebsd do
      sequence(:name) { 'FreeBSD' }
      major { '11' }
      minor { '2' }
      type { 'Freebsd' }
      title { 'FreeBSD 11.2' }
    end
  end
end
