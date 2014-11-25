FactoryGirl.define do
  factory :compute_resource do
    sequence(:name) { |n| "compute_resource#{n}" }
    sequence(:url) { |n| "http://#{n}.example.com/" }

    trait :ec2 do
      provider 'EC2'
      user 'ec2user'
      password 'ec2password'
      url 'eu-west-1'
      after(:build) { |host| host.class.skip_callback(:create, :after, :setup_key_pair) }
    end

    trait :gce do
      provider 'GCE'
      key_path Rails.root
      project 'gce_project'
      sequence(:email) { |n| "user#{n}@example.com" }
    end

    trait :libvirt do
      provider 'Libvirt'
    end

    trait :openstack do
      provider 'Openstack'
      user 'osuser'
      password 'ospassword'
      after(:build) { |host| host.class.skip_callback(:create, :after, :setup_key_pair) }
    end

    trait :ovirt do
      provider 'Ovirt'
      user 'ovirtuser'
      password 'ovirtpassword'
      after(:build) { |host| host.class.skip_callback(:create, :before, :update_public_key) }
    end

    trait :rackspace do
      provider 'Rackspace'
      user 'rsuser'
      password 'rspassword'
      region 'IAD'
    end

    trait :vmware do
      provider 'Vmware'
      user 'vuser'
      password 'vpassword'
      sequence(:server) { |n| "#{n}.example.com" }
      datacenter 'vdatacenter'
      after(:build) { |host| host.class.skip_callback(:create, :before, :update_public_key) }
    end

    factory :ec2_cr, :class => Foreman::Model::EC2, :traits => [:ec2]
    factory :gce_cr, :class => Foreman::Model::GCE, :traits => [:gce]
    factory :libvirt_cr, :class => Foreman::Model::Libvirt, :traits => [:libvirt]
    factory :openstack_cr, :class => Foreman::Model::Openstack, :traits => [:openstack]
    factory :ovirt_cr, :class => Foreman::Model::Ovirt, :traits => [:ovirt]
    factory :rackspace_cr, :class => Foreman::Model::Rackspace, :traits => [:rackspace]
    factory :vmware_cr, :class => Foreman::Model::Vmware, :traits => [:vmware]
  end

  factory :image do
    sequence(:name) { |n| "image#{n}" }
    uuid Foreman.uuid
    username 'root'
    compute_resource
    operatingsystem
    architecture
  end
end
