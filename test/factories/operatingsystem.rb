FactoryGirl.define do
  factory :operatingsystem, class: Operatingsystem do
    sequence(:name) { |n| "operatingsystem#{n}" }
    sequence(:major) { |n| n }

    factory :coreos, class: Coreos do
      association :media, :architecture, :ptables
      sequence(:name) { 'CoreOS' }
      major '494'
      minor '5.0'
      type 'Coreos'
      release_name 'stable'
      title 'CoreOS 494.5.0'
    end

    factory :ubuntu14_10, class: Debian do
      association :media, :architecture, :ptables
      sequence(:name) { 'Ubuntu' }
      major '14'
      minor '10'
      type 'Debian'
      release_name 'utopic'
      title 'Ubuntu Utopic'
    end

    factory :debian7_0, class: Debian do
      association :media, :architecture, :ptables
      sequence(:name) { 'Debian' }
      major '7'
      minor '0'
      type 'Debian'
      release_name 'wheezy'
      title 'Debian Wheezy'
    end

    factory :suse, class: Suse do
      association :media, :architecture, :ptables
      sequence(:name) { 'OpenSuse' }
      major '11'
      minor '4'
      type 'Suse'
      title 'OpenSuse 11.4'
    end
  end
end