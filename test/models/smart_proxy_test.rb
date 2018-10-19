require 'test_helper'

class SmartProxyTest < ActiveSupport::TestCase
  should allow_values(*valid_name_list).for(:name)
  should_not allow_values('', ' ', '\t', nil, 'invalid url').for(:url)

  test "should not create smart_proxy with invalid name" do
    invalid_name_list.each do |invalid_name|
      smart_proxy = FactoryBot.build(:smart_proxy, :name => invalid_name, :url => 'https://valid.url:4568')
      refute_valid smart_proxy
      assert_includes smart_proxy.errors.keys, :name
    end
  end

  context 'url validations' do
    setup do
      @proxy = FactoryBot.
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
    ProxyAPI::Features.any_instance.stubs(:features => Feature.name_map.keys)
    @proxy = FactoryBot.build(:smart_proxy)
    @proxy.url = 'http://some.proxy:4568/'
    as_admin { assert @proxy.save }
    assert_equal @proxy.url, "http://some.proxy:4568"
  end

  test "proxy should respond correctly to has_feature? method" do
    proxy = FactoryBot.build_stubbed(:template_smart_proxy)
    assert proxy.has_feature?('Templates')
    refute proxy.has_feature?('Puppet CA')
  end

  # test taxonomix methods
  test "should get used location ids for host" do
    FactoryBot.create(:host, :with_environment, :puppet_proxy => smart_proxies(:puppetmaster),
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
    proxy = FactoryBot.create(:puppet_smart_proxy)
    FactoryBot.create(:host, :with_environment, :puppet_proxy => proxy)
    as_admin do
      assert_equal 1, proxy.hosts_count
    end
  end

  test "should be saved if features exist" do
    proxy = FactoryBot.build(:smart_proxy)
    ProxyAPI::Features.any_instance.stubs(:features => ["tftp"])
    assert proxy.save
    assert_include(proxy.features, features(:tftp))
  end

  test "should not be saved if features do not exist" do
    proxy = SmartProxy.new(:name => 'Proxy', :url => 'https://some.where.net:8443')
    error_message = 'Features "feature" in this proxy are not recognized by Foreman. '\
    'If these features come from a Smart Proxy plugin, make sure Foreman has the plugin installed too.'
    ProxyAPI::Features.any_instance.stubs(:features => ["feature"])
    refute proxy.save
    assert_equal(error_message, proxy.errors[:base].first)
  end

  test "should not be saved if features are not array" do
    proxy = SmartProxy.new(:name => 'Proxy', :url => 'https://some.where.net:8443')
    ProxyAPI::Features.any_instance.stubs(:features => {:fe => :at, :ur => :e})
    refute proxy.save
    assert_equal('An invalid response was received while requesting available features from this proxy', proxy.errors[:base].first)
  end

  describe '#ping' do
    let(:proxy) { SmartProxy.new(name: 'Proxy', url: 'https://some.where.net:8443') }

    test 'pings the smart proxy' do
      ProxyAPI::Features.any_instance.stubs(:features).returns(['logs', 'puppetca', 'templates'])
      assert proxy.ping
      assert_empty proxy.errors
    end

    test 'is false when there are connection errors' do
      ProxyAPI::Features.any_instance.stubs(:features).raises(Errno::ECONNREFUSED)
      refute proxy.ping
      refute_empty proxy.errors
    end
  end
end
