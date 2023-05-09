require 'test_helper'

module Types
  class ProviderEnumTest < ActiveSupport::TestCase
    def setup
      plugin1 = stub('plugin1', :compute_resources => ['Best::Provider::MyBest'])
      Foreman::Plugin.stubs(:all).returns([plugin1])

      reload_enum
    end

    def teardown
      reload_enum
    end

    def reload_enum
      Types.send(:remove_const, :ProviderEnum) if Types.constants.include?(:ProviderEnum)
      load 'app/graphql/types/provider_enum.rb'
    end

    let(:enum) { Types::ProviderEnum }

    test 'contains all supported providers' do
      assert_includes enum.values.keys, 'Libvirt'
      assert_includes enum.values.keys, 'Ovirt'
      assert_includes enum.values.keys, 'EC2'
      assert_includes enum.values.keys, 'Vmware'
      assert_includes enum.values.keys, 'Openstack'
    end

    test 'contains registered providers from plugins' do
      assert_includes enum.values.keys, 'MyBest'
    end
  end
end
