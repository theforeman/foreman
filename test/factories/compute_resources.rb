FactoryGirl.define do
  factory :compute_resource do
    sequence(:name) { |n| "compute_resource#{n}" }
    sequence(:url) { |n| "http://#{n}.example.com/" }

    trait :ec2 do
      provider 'EC2'
      user 'ec2user'
      password 'ec2password'
      url 'eu-west-1'
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
    end

    trait :ovirt do
      provider 'Ovirt'
      user 'ovirtuser'
      password 'ovirtpassword'
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
    end

    factory :ec2_cr, :traits => [:ec2]
    factory :gce_cr, :traits => [:gce]
    factory :libvirt_cr, :traits => [:libvirt]
    factory :openstack_cr, :traits => [:openstack]
    factory :ovirt_cr, :traits => [:ovirt]
    factory :rackspace_cr, :traits => [:rackspace]
    factory :vmware_cr, :traits => [:vmware]
  end
end
