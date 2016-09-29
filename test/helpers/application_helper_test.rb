require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  def test_generate_link_for
    proxy = FactoryGirl.create(:dhcp_smart_proxy)
    subnet = FactoryGirl.create(:subnet_ipv4, :name => 'My subnet')
    proxy.subnets = [subnet]
    links = generate_links_for(proxy.subnets)
    assert_equal(link_to(subnet.to_label, subnets_path(:search => "name = \"#{subnet.name}\"")), links)
  end

  describe 'documentation' do
    test '#documentation_url returns global url if no section specified' do
      url = documentation_url

      assert_match /documentation.html/, url
    end

    test '#documentation_url returns foreman docs url with a given section' do
      url = documentation_url '1.1TestSection'

      assert_match /TestSection/, url
      assert_match /manuals/, url
    end

    test '#documentation_url receives a root_url option' do
      url = documentation_url '2.2PluginSection', :root_url => 'http://www.theforeman.org/my_plugin/v0.1/index.html#'

      assert_match /PluginSection/, url
      assert_match /my_plugin/, url
    end

    test '#documentation_button forwards options to #documentation_url' do
      expects(:icon_text).returns('http://nowhere.com')
      expects(:link_to).returns('<a>test</a>'.html_safe)
      expects(:documentation_url).with('2.2PluginSection', { :root_url => 'http://www.theforeman.org/my_plugin/v0.1/index.html#' })

      documentation_button '2.2PluginSection', :root_url => 'http://www.theforeman.org/my_plugin/v0.1/index.html#'
    end
  end
end
