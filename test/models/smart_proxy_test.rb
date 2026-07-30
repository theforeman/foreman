require 'test_helper'

class SmartProxyTest < ActiveSupport::TestCase
  should allow_values(*valid_name_list).for(:name)
  should_not allow_values('', ' ', '\t', nil, 'invalid url').for(:url)

  test "should not create smart_proxy with invalid name" do
    invalid_name_list.each do |invalid_name|
      smart_proxy = FactoryBot.build(:smart_proxy, :name => invalid_name, :url => 'https://valid.url:4568')
      refute_valid smart_proxy
      assert_includes smart_proxy.errors.attribute_names, :name
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
  test "should get used and selected location ids for host" do
    assert_equal [taxonomies(:location1).id], smart_proxies(:puppetmaster).used_or_selected_location_ids
  end

  describe '#used_taxonomy_ids' do
    let(:location1) { taxonomies(:location1) }
    let(:location2) { taxonomies(:location2) }
    let(:organization1) { taxonomies(:organization1) }
    let(:organization2) { taxonomies(:organization2) }
    let(:organization3) { taxonomies(:empty_organization) }

    test 'returns empty array for a new unsaved proxy' do
      proxy = SmartProxy.new(:name => 'New', :url => 'https://new.proxy:8443')
      assert_empty proxy.used_taxonomy_ids(:location_id)
      assert_empty proxy.used_taxonomy_ids(:organization_id)
    end

    test 'returns empty array when no managed host references the proxy' do
      proxy = FactoryBot.create(:smart_proxy,
        :locations => [location1],
        :organizations => [organization1])
      assert_empty proxy.used_taxonomy_ids(:location_id)
      assert_empty proxy.used_taxonomy_ids(:organization_id)
    end

    test 'returns intersection of organizations on proxy and organizations of hosts using the proxy' do
      as_admin do
        proxy = FactoryBot.create(:smart_proxy,
          :locations => [location1],
          :organizations => [organization1, organization2])
        FactoryBot.create(:host, :managed,
          :puppet_proxy => proxy,
          :location => location1,
          :organization => organization2)
        FactoryBot.create(:host, :managed,
          :puppet_proxy => proxy,
          :location => location1,
          :organization => organization3)

        assert_equal [organization2.id], proxy.reload.used_taxonomy_ids(:organization_id)
        assert_includes proxy.host_taxonomy_ids_outside_proxy_assignment(:organization_id), organization3.id
        refute_includes proxy.host_taxonomy_ids_outside_proxy_assignment(:organization_id), organization2.id
      end
    end
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
      assert_equal ['feature'], proxy.unrecognized_features
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

    test "should store unrecognized features when proxy has mix of known and unknown" do
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns(
        'tftp' => {'state' => 'running'},
        'unknown_plugin' => {'state' => 'running'},
        'another_unknown' => {'state' => 'running'}
      )
      proxy = FactoryBot.build(:smart_proxy)
      assert proxy.save
      proxy.reload
      assert_include(proxy.features, features(:tftp))
      assert_equal %w[unknown_plugin another_unknown].sort, proxy.unrecognized_features.sort
    end

    test "should clear unrecognized features when all proxy features are known" do
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns(
        'tftp' => {'state' => 'running'}
      )
      proxy = FactoryBot.build(:smart_proxy)
      assert proxy.save
      proxy.reload
      assert_empty proxy.unrecognized_features
    end

    test "should populate unrecognized features even when no valid features exist" do
      proxy = SmartProxy.new(:name => 'Proxy', :url => 'https://some.where.net:8443')
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns({'unknown_feature' => {'state' => 'running'}})
      refute proxy.save
      assert_equal ['unknown_feature'], proxy.unrecognized_features
    end

    test "should clear previously stored unrecognized features on re-save" do
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns(
        'tftp' => {'state' => 'running'},
        'unknown_plugin' => {'state' => 'running'}
      )
      proxy = FactoryBot.build(:smart_proxy)
      assert proxy.save
      proxy.reload
      assert_equal ['unknown_plugin'], proxy.unrecognized_features

      ProxyAPI::V2::Features.any_instance.stubs(:features).returns(
        'tftp' => {'state' => 'running'}
      )
      assert proxy.save
      proxy.reload
      assert_empty proxy.unrecognized_features
    end

    test "should return empty array for unrecognized_features when column is NULL" do
      proxy = FactoryBot.build(:smart_proxy)
      ProxyAPI::V2::Features.any_instance.stubs(:features).returns('tftp' => {'state' => 'running'})
      proxy.save!
      SmartProxy.where(id: proxy.id).update_all(unrecognized_features: nil)
      proxy.reload
      assert_empty proxy.unrecognized_features
    end

    test "should store unrecognized features with v1 api when proxy has mix of known and unknown" do
      proxy = FactoryBot.build(:smart_proxy)
      ProxyAPI::V2::Features.any_instance.stubs(:features).raises(NotImplementedError)
      ProxyAPI::Features.any_instance.stubs(:features => ["tftp", "unknown_v1_plugin"])
      assert proxy.save
      proxy.reload
      assert_include(proxy.features.map(&:name), "TFTP")
      assert_equal ['unknown_v1_plugin'], proxy.unrecognized_features
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

  describe '#self_or_colocated_with_feature' do
    test 'returns a proxy on the same host with the requested feature' do
      proxy_a = FactoryBot.create(:template_smart_proxy, :url => 'https://colocated.example.com:8443')
      proxy_b = FactoryBot.create(:smart_proxy, :url => 'https://colocated.example.com:9090')
      proxy_b.smart_proxy_features << FactoryBot.build(:smart_proxy_feature, :tftp, :smart_proxy => proxy_b)

      assert_equal proxy_a, proxy_b.self_or_colocated_with_feature('Templates')
    end

    test 'returns nil when no co-located proxy has the feature' do
      proxy = FactoryBot.create(:smart_proxy, :url => 'https://lonely.example.com:8443')

      assert_nil proxy.self_or_colocated_with_feature('Templates')
    end

    test 'returns self when self has the requested feature' do
      proxy = FactoryBot.create(:template_smart_proxy, :url => 'https://selfmatch.example.com:8443')

      assert_equal proxy, proxy.self_or_colocated_with_feature('Templates')
    end

    test 'does not match proxies on different hosts' do
      FactoryBot.create(:template_smart_proxy, :url => 'https://other.example.com:8443')
      proxy = FactoryBot.create(:smart_proxy, :url => 'https://different.example.com:8443')
      proxy.smart_proxy_features.destroy_all

      assert_nil proxy.self_or_colocated_with_feature('Templates')
    end
  end
end
