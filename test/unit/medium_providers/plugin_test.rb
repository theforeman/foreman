require 'test_helper'

class PluginMediumProviderTest < ActiveSupport::TestCase
  class PluginMediumProvider < MediumProviders::Provider
    def medium_uri(path = "", &block)
      '/medium'
    end

    def valid?
      true
    end
  end

  setup do
    Foreman::Plugin.medium_providers.register(PluginMediumProvider)
  end

  teardown do
    Foreman::Plugin.medium_providers.unregister(PluginMediumProvider)
  end

  test 'plugin can provide media without medium set' do
    host = FactoryBot.create(:host, :with_operatingsystem, medium: nil)
    medium_provider = Foreman::Plugin.medium_providers.find_provider(host)
    assert_nil host.medium
    assert_instance_of PluginMediumProvider, medium_provider
  end
end
