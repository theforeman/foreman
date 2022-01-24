require 'test_helper'

class GeneralSettingTest < ActiveSupport::TestCase
  describe 'HTTP Proxy settings' do
    test 'http_proxy must be HTTP(S) URL' do
      setting = Foreman.settings.set_user_value('http_proxy', 'http://dummy.theforeman.org:3218')
      assert_valid setting
    end

    test 'http_proxy setting can be empty' do
      setting = Foreman.settings.set_user_value('http_proxy', '')
      assert_valid setting
    end

    test 'http_proxy setting can not be a unix socket' do
      setting = Foreman.settings.set_user_value('http_proxy', 'unix://dev/null')
      refute_valid setting
    end
  end
end
