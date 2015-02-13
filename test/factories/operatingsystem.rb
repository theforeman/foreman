FactoryGirl.define do
  factory :operatingsystem, class: Operatingsystem do
    sequence(:name) { |n| "operatingsystem#{n}" }
    sequence(:major) { |n| n }

    trait :with_os_defaults do
      after(:create) do |os,evaluator|
        os.config_templates.each do |tmpl|
          FactoryGirl.create(:os_default_template,
                             :operatingsystem => os,
                             :config_template => tmpl,
                             :template_kind => tmpl.template_kind)
        end
      end
    end

    trait :with_provision do
      config_templates {
        [FactoryGirl.create(:config_template, :template_kind => TemplateKind.find_by_name('provision'))]
      }
      with_os_defaults
    end

    trait :with_archs do
      architectures { [FactoryGirl.create(:architecture)] }
    end

    trait :with_media do
      media { [FactoryGirl.create(:medium)] }
    end

    trait :with_ptables do
      ptables { [FactoryGirl.create(:ptable)] }
    end

    trait :with_associations do
      with_archs
      with_media
      with_ptables
    end

    factory :coreos, class: Coreos do
      sequence(:name) { 'CoreOS' }
      major '494'
      minor '5.0'
      type 'Coreos'
      release_name 'stable'
      title 'CoreOS 494.5.0'
    end

    factory :ubuntu14_10, class: Debian do
      sequence(:name) { 'Ubuntu' }
      major '14'
      minor '10'
      type 'Debian'
      release_name 'utopic'
      title 'Ubuntu Utopic'
    end

    factory :debian7_0, class: Debian do
      sequence(:name) { 'Debian' }
      major '7'
      minor '0'
      type 'Debian'
      release_name 'wheezy'
      title 'Debian Wheezy'
    end

    factory :suse, class: Suse do
      sequence(:name) { 'OpenSuse' }
      major '11'
      minor '4'
      type 'Suse'
      title 'OpenSuse 11.4'
    end
  end
end
