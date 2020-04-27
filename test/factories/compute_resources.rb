FactoryBot.define do
  factory :compute_resource do
    sequence(:name) { |n| "compute_resource#{n}" }
    sequence(:url) { |n| "http://#{n}.example.com/" }
    organizations { [Organization.find_by_name('Organization 1')] }
    locations { [Location.find_by_name('Location 1')] }

    trait :ec2 do
      provider { 'EC2' }
      user { 'ec2user' }
      password { 'ec2password' }
      url { 'eu-west-1' }
      after(:build) { |cr| cr.stubs(:setup_key_pair) }
    end

    trait :gce do
      provider { 'GCE' }
      key_path { 'gce_config.json' }
      project { 'gce_project' }
      zone { 'us-west1-a' }
      sequence(:email) { |n| "user#{n}@example.com" }
      after(:stub) do |cr|
        cr.stubs(:zones).returns(
          ['us-west1-b', 'us-west1-c', 'us-west1-a', 'us-east1-b', 'us-east1-c', 'us-east1-d']
        )
      end
      after(:build) do |cr|
        cr.stubs(:setup_key_pair)
        cr.stubs(:zones).returns(
          ['us-west1-b', 'us-west1-c', 'us-west1-a', 'us-east1-b', 'us-east1-c', 'us-east1-d']
        )
        cr.stubs(:read_key_file).returns(
          {
            'type' => 'service_account',
            'project_id' => 'dummy-project',
            'private_key' => '-----BEGIN PRIVATE KEY-----\n..\n-----END PRIVATE KEY-----\n ',
            'client_email' => 'dummy@dummy-project.iam.gserviceaccount.com',
          }
        )
      end
    end

    trait :libvirt do
      provider { 'Libvirt' }
    end

    trait :openstack do
      provider { 'Openstack' }
      user { 'osuser' }
      password { 'ospassword' }
      url { 'http://openstack.example.com/v2.0' }
      after(:build) { |cr| cr.stubs(:setup_key_pair) }
    end

    trait :ovirt do
      provider { 'Ovirt' }
      user { 'ovirtuser' }
      password { 'ovirtpassword' }
      after(:build) { |cr| cr.stubs(:update_public_key) }
    end

    trait :vmware do
      provider { 'Vmware' }
      user { 'vuser' }
      password { 'vpassword' }
      sequence(:url) { |n| "#{n}.example.com" } # alias for server
      uuid { 'vdatacenter' } # alias for datacenter
      after(:build) { |cr| cr.stubs(:update_public_key) }
    end

    trait :with_images do
      after(:create) do |cr, evaluator|
        cr.stubs(:image_exists?).returns(true)
        FactoryBot.create(:image, :compute_resource => cr)
        FactoryBot.create(:image, :compute_resource => cr)
      end
    end

    factory :ec2_cr, :class => Foreman::Model::EC2, :traits => [:ec2]
    factory :gce_cr, :class => Foreman::Model::GCE, :traits => [:gce]
    factory :libvirt_cr, :class => Foreman::Model::Libvirt, :traits => [:libvirt]
    factory :openstack_cr, :class => Foreman::Model::Openstack, :traits => [:openstack]
    factory :ovirt_cr, :class => Foreman::Model::Ovirt, :traits => [:ovirt]
    factory :vmware_cr, :class => Foreman::Model::Vmware, :traits => [:vmware]
  end

  factory :image do
    sequence(:name) { |n| "image#{n}" }
    uuid { Foreman.uuid }
    username { 'root' }
    association :compute_resource, factory: :libvirt_cr
    operatingsystem
    architecture
  end

  factory :compute_attribute do
    sequence(:name) { |n| "attributes#{n}" }
    vm_attrs do
      {
        :flavor_id => 'm1.small',
        :availability_zone => 'eu-west-1a',
      }
    end
    before(:create) { |attr| attr.stubs(:pretty_vm_attrs).returns('m1.small VM') }
  end

  factory :compute_profile do
    sequence(:name) { |n| "profile#{n}" }

    trait :with_compute_attribute do
      transient do
        compute_resource { nil }
      end

      after(:create) do |compute_profile, evaluator|
        compute_profile.compute_attributes << FactoryBot.create(:compute_attribute,
          :compute_resource => evaluator.compute_resource,
          :compute_profile => compute_profile
        )
      end
    end
  end
end
