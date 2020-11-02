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

  test "proxy should respond correctly to has_feature? method" do
    proxy = FactoryBot.build(:template_smart_proxy)
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

  describe "with older smart proxy on v1 api" do
    before do
      ProxyAPI::V2::Features.any_instance.stubs(:features).raises(NotImplementedError.new('not supported'))
    end

    test "should not include trailing slash" do
      ProxyAPI::Features.any_instance.stubs(:features => Feature.name_map.keys)
      @proxy = FactoryBot.build(:smart_proxy)
      @proxy.url = 'http://some.proxy:4568/'

      as_admin do
        assert @proxy.save
      end
      assert_equal @proxy.url, "http://some.proxy:4568"
    end

    test "should be saved if features exist" do
      proxy = FactoryBot.build(:smart_proxy)
      ProxyAPI::Features.any_instance.stubs(:features => ["tftp"])
      assert proxy.save
      assert_include(proxy.reload.features, features(:tftp))
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
      ProxyAPI::Features.any_instance.stubs(:features => :fe)
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

  describe "with v2 api" do
    test "should be saved if features exist" do
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns(:tftp => {:settings => {}, :capabilities => [], :state => 'running'}, :puppet => {:state => 'not_running'})
      proxy = FactoryBot.build(:smart_proxy)

      assert proxy.save
      assert_include(proxy.reload.features, features(:tftp))
      refute_includes(proxy.reload.features, features(:puppet))
    end

    test "should not be saved if features do not exist" do
      proxy = SmartProxy.new(:name => 'Proxy', :url => 'https://some.where.net:8443')
      error_message = 'Features "feature" in this proxy are not recognized by Foreman. '\
      'If these features come from a Smart Proxy plugin, make sure Foreman has the plugin installed too.'

      ProxyAPI::V2::Features.any_instance.stubs(:features).returns({'feature' => {'state' => 'running'}})
      refute proxy.save
      assert_equal(error_message, proxy.errors[:base].first)
    end

    test "can import and access capabilities and settings" do
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns(:tftp => {:settings => {:foo => :bar}, :capabilities => ['FOO'], :state => 'running'})
      proxy = FactoryBot.build(:smart_proxy)
      proxy.save!
      proxy.reload

      assert_include proxy.capabilities('TFTP'), 'FOO'
      assert_equal 'bar', proxy.setting('TFTP', 'foo')
    end

    test "can access httpboot_http_port exposed setting" do
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns(:httpboot => {:settings => {:http_port => 1234}, :state => 'running'})
      proxy = FactoryBot.build(:httpboot_smart_proxy)
      proxy.save!
      proxy.reload

      assert_equal 1234, proxy.httpboot_http_port
    end

    test "can access httpboot_https_port exposed setting" do
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns(:httpboot => {:settings => {:https_port => 1234}, :state => 'running'})
      proxy = FactoryBot.build(:httpboot_smart_proxy)
      proxy.save!
      proxy.reload

      assert_equal 1234, proxy.httpboot_https_port
    end

    describe '#ping' do
      let(:proxy) { SmartProxy.new(name: 'Proxy', url: 'https://some.where.net:8443') }

      test 'pings the smart proxy' do
        ProxyAPI::V2::Features.any_instance.stubs(:features).returns(:tftp => {:settings => {}, :capabilities => []})
        assert proxy.ping
        assert_empty proxy.errors
      end

      test 'is false when there are connection errors' do
        ProxyAPI::V2::Features.any_instance.stubs(:features).raises(Errno::ECONNREFUSED)
        refute proxy.ping
        refute_empty proxy.errors
      end
    end
  end
end
