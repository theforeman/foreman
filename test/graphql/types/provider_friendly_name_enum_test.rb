require 'test_helper'

module Best
  module Provider
    class MyBest < ::ComputeResource; end
  end
end

module Types
  class ProviderFriendlyNameEnumTest < ActiveSupport::TestCase
    def setup
      plugin1 = stub('plugin1', :compute_resources => ['Best::Provider::MyBest'])
      Foreman::Plugin.stubs(:all).returns([plugin1])

      reload_enum
    end

    def teardown
      reload_enum
    end

    def reload_enum
      Types.send(:remove_const, :ProviderFriendlyNameEnum) if Types.constants.include?(:ProviderFriendlyNameEnum)
      load 'app/graphql/types/provider_friendly_name_enum.rb'
    end

    let(:enum) { Types::ProviderFriendlyNameEnum }

    test 'contains all supported providers' do
      assert_includes enum.values.keys, 'Libvirt'
      assert_includes enum.values.keys, 'oVirt'
      assert_includes enum.values.keys, 'EC2'
      assert_includes enum.values.keys, 'VMware'
      assert_includes enum.values.keys, 'OpenStack'
    end

    test 'contains registered providers from plugins' do
      assert_includes enum.values.keys, 'MyBest'
    end
  end
end
