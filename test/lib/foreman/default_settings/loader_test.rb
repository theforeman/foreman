require 'test_helper'
require 'puppet_setting'
require 'foreman/default_settings/loader'

class DefaultSettingsLoaderTest < ActiveSupport::TestCase
  # Check one of the puppetmaster sourced settings was loaded
  test "should initialize hostcert from Puppet" do
    PuppetSetting.any_instance.stubs(:get).returns({:hostcert => '/var/lib/puppet/mycert.pem'})
    Foreman::DefaultSettings::Loader.load
    assert_equal '/var/lib/puppet/mycert.pem', Setting.find_by_name('ssl_certificate').value
  end
end

