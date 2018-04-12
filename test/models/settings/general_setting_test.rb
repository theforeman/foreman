require 'test_helper'

class GeneralSettingTest < ActiveSupport::TestCase
  describe 'HTTP Proxy settings' do
    let(:attrs) do
      { :name => "http_proxy", :default => nil, :description => "desc",
        :category => "Setting::General" }
    end
    let(:http_proxy_setting) do
      Setting.where(:name => attrs[:name]).first || Setting.create(attrs)
    end

    test 'http_proxy must be HTTP(S) URL' do
      http_proxy_setting.value = 'http://dummy.theforeman.org:3218'
      assert_valid http_proxy_setting
    end

    test 'http_proxy setting can be empty' do
      http_proxy_setting.value = ''
      assert_valid http_proxy_setting
    end

    test 'http_proxy setting can not be a unix socket' do
      http_proxy_setting.value = 'unix://dev/null'
      refute_valid http_proxy_setting
    end
  end
end
