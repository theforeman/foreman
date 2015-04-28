require 'test_helper'

class SmartProxyTest < ActiveSupport::TestCase
  test "should be valid" do
    proxy = SmartProxy.new
    proxy.name = "test proxy"
    proxy.url  = "https://secure.proxy:4568"
    assert proxy.valid?
  end

  test "should not be modified if has no leading slashes" do
    proxy = SmartProxy.new
    proxy.name = "test proxy"
    proxy.url  = "https://secure.proxy:4568"
    assert proxy.valid?
    assert_equal proxy.url, "https://secure.proxy:4568"
  end

  test "should not include trailing slash" do
    proxy = SmartProxy.new
    proxy.name = "test a proxy"
    proxy.url  = "http://some.proxy:4568/"
    as_admin do
      assert proxy.save
    end
    assert_equal proxy.url, "http://some.proxy:4568"
  end

  test "should honor legacy puppet hostname true setting" do
    Setting[:legacy_puppet_hostname] = true
    proxy = SmartProxy.new
    proxy.name = "test proxy"
    proxy.url = "http://puppet.example.com:4568"

    assert_equal proxy.to_s, "puppet"
  end

  test "should honor legacy puppet hostname false setting" do
    Setting[:legacy_puppet_hostname] = false
    proxy = SmartProxy.new
    proxy.name = "test proxy"
    proxy.url = "http://puppet.example.com:4568"

    assert_equal proxy.to_s, "puppet.example.com"
  end

  test "proxy should respond correctly to has_feature? method" do
    proxy = FactoryGirl.create(:template_smart_proxy)
    assert proxy.has_feature?('Templates')
    refute proxy.has_feature?('Puppet CA')
  end

  # test taxonomix methods
  test "should get used location ids for host" do
    FactoryGirl.create(:host, :puppet_proxy => smart_proxies(:puppetmaster),
                       :location => taxonomies(:location1))
    assert_equal ["Puppet", "Puppet CA"], smart_proxies(:puppetmaster).features.pluck(:name).sort
    assert_equal [taxonomies(:location1).id], smart_proxies(:puppetmaster).used_location_ids
  end

  test "should get used and selected location ids for host" do
    assert_equal [taxonomies(:location1).id], smart_proxies(:puppetmaster).used_or_selected_location_ids
  end
end
