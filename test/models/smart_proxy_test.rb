require 'test_helper'

class SmartProxyTest < ActiveSupport::TestCase
  context 'url validations' do
    setup do
      @proxy = FactoryGirl.
        build_stubbed(:smart_proxy, :url => 'https://secure.proxy:4568')
    end

    test "should be valid" do
      assert_valid @proxy
    end

    test "should not be modified if has no leading slashes" do
      assert_equal @proxy.url, "https://secure.proxy:4568"
    end
  end

  test "should not include trailing slash" do
    @proxy = FactoryGirl.build(:smart_proxy)
    @proxy.url = 'http://some.proxy:4568/'
    as_admin { assert @proxy.save }
    assert_equal @proxy.url, "http://some.proxy:4568"
  end

  context 'legacy puppet hostname' do
    setup do
      @proxy = FactoryGirl.build_stubbed(:smart_proxy)
      @proxy.url = "http://puppet.example.com:4568"
    end

    test "when true returns puppet part of hostname" do
      Setting.expects(:[]).with(:legacy_puppet_hostname).returns(true)
      assert_equal "puppet", @proxy.to_s
    end

    test "when false returns whole hostname" do
      Setting.expects(:[]).with(:legacy_puppet_hostname).returns(false)
      assert_equal "puppet.example.com", @proxy.to_s
    end
  end

  test "proxy should respond correctly to has_feature? method" do
    proxy = FactoryGirl.build_stubbed(:template_smart_proxy)
    assert proxy.has_feature?('Templates')
    refute proxy.has_feature?('Puppet CA')
  end

  # test taxonomix methods
  test "should get used location ids for host" do
    FactoryGirl.create(:host, :with_environment, :puppet_proxy => smart_proxies(:puppetmaster),
                       :location => taxonomies(:location1))
    assert_equal ["Puppet", "Puppet CA"], smart_proxies(:puppetmaster).features.pluck(:name).sort
    assert_equal [taxonomies(:location1).id], smart_proxies(:puppetmaster).used_location_ids
  end

  test "should get used and selected location ids for host" do
    assert_equal [taxonomies(:location1).id], smart_proxies(:puppetmaster).used_or_selected_location_ids
  end

  test "should return environment stats" do
    proxy = smart_proxies(:puppetmaster)
    ProxyAPI::Puppet.any_instance.expects(:environments).returns(['env1', 'env2'])
    ProxyAPI::Puppet.any_instance.expects(:class_count).with('env1').returns(1)
    ProxyAPI::Puppet.any_instance.expects(:class_count).with('env2').returns(2)
    assert_equal({'env1' => 1, 'env2' => 2}, proxy.statuses[:puppet].environment_stats)
  end

  test "can count connected hosts" do
    proxy = FactoryGirl.create(:puppet_smart_proxy)
    FactoryGirl.create(:host, :with_environment, :puppet_proxy => proxy)
    as_admin do
      assert_equal 1, proxy.hosts_count
    end
  end
end
