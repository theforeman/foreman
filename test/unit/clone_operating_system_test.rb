require 'test_helper'

class CloneOperatingSystemTest < ActiveSupport::TestCase
  context 'clone_obj' do
    setup do
      @original_os = FactoryBot.create(:operatingsystem,
        :with_provision,
        :with_associations,
        :with_parameter,
        name: 'TestOS',
        major: '9',
        minor: '0',
        title: 'TestOS 9.0')

      @original_os.reload
      @override_attrs = {
        name: 'TestOS',
        major: '10',
      }
    end

    test 'should clone operating system with all associations' do
      cloned_os = CloneOperatingSystem.clone_obj(@original_os, @override_attrs)
      cloned_os.save!
      cloned_os.reload

      assert_equal @original_os.name, cloned_os.name
      assert_equal '10', cloned_os.major
      assert_equal '0', cloned_os.minor

      assert_equal @original_os.media.count, cloned_os.media.count
      assert_equal @original_os.ptables.count, cloned_os.ptables.count
      assert_equal @original_os.architectures.count, cloned_os.architectures.count
      assert_equal @original_os.os_parameters.count, cloned_os.os_parameters.count
      assert_equal @original_os.provisioning_templates.count, cloned_os.provisioning_templates.count
      assert_equal @original_os.os_default_templates.count, cloned_os.os_default_templates.count
    end

    test 'skip save on cloned object' do
      cloned_os = CloneOperatingSystem.clone_obj(@original_os, @override_attrs)
      assert_not cloned_os.persisted?
    end

    test 'should exclude title from cloning' do
      cloned_os = CloneOperatingSystem.clone_obj(@original_os, @override_attrs)
      assert_nil cloned_os.title
    end

    test 'should exclude description from cloning' do
      cloned_os = CloneOperatingSystem.clone_obj(@original_os, @override_attrs)
      assert_nil cloned_os.description
    end
  end

  context 'find_candidate_to_clone' do
    context 'without minor version' do
      setup do
        @rhel7 = FactoryBot.create(:operatingsystem, name: 'TestOS', major: '7')
        @rhel9 = FactoryBot.create(:operatingsystem, name: 'TestOS', major: '9')
      end

      test 'should return nil when no OS with lower major version exists' do
        assert_nil CloneOperatingSystem.find_candidate_to_clone('TestOS', '6')
      end

      test 'should return OS with highest major version lower than target' do
        assert_equal @rhel9.id, CloneOperatingSystem.find_candidate_to_clone('TestOS', '10')&.id
      end

      test 'higher major versions are ignored' do
        assert_equal @rhel7.id, CloneOperatingSystem.find_candidate_to_clone('TestOS', '8')&.id
      end

      test 'should raise error if os already exists' do
        assert_raises Foreman::Exception do
          CloneOperatingSystem.find_candidate_to_clone('TestOS', '7')
        end
      end
    end

    context 'with minor version' do
      setup do
        @os = FactoryBot.create(:operatingsystem, name: 'TestOS', major: '7', minor: '5')
      end

      test 'should return nil when no OS with lower major or minor version exists' do
        assert_nil CloneOperatingSystem.find_candidate_to_clone('TestOS', '7', '2')
      end

      test 'should return OS with same major' do
        assert_equal @os.id, CloneOperatingSystem.find_candidate_to_clone('TestOS', '7', '6')&.id
      end

      test 'should return lower major version when no same major with lower minor exists' do
        assert_equal @os.id, CloneOperatingSystem.find_candidate_to_clone('TestOS', '8', '0')&.id
      end

      test 'should raise error if os already exists' do
        assert_raises Foreman::Exception do
          CloneOperatingSystem.find_candidate_to_clone('TestOS', '7', '5')
        end
      end
    end
  end
end
