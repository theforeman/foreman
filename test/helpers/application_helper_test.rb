require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  def test_generate_link_for
    proxy = FactoryBot.create(:dhcp_smart_proxy)
    subnet = FactoryBot.create(:subnet_ipv4, :name => 'My subnet')
    proxy.subnets = [subnet]
    links = generate_links_for(proxy.subnets)
    assert_equal(link_to(subnet.to_label, subnets_path(:search => "name = \"#{subnet.name}\"")), links)
  end

  describe 'documentation' do
    test '#documentation_url returns global url if no section specified' do
      url = documentation_url

      assert_match /manual/, url
    end

    test '#documentation_url returns foreman docs url with a given section' do
      url = documentation_url '1.1TestSection'

      assert_match /TestSection/, url
      assert_match /manual/, url
    end

    test '#documentation_url receives a root_url option' do
      url = documentation_url '2.2PluginSection', :root_url => 'http://www.theforeman.org/my_plugin/v0.1/index.html#'

      assert_match /PluginSection/, url
      assert_match /my_plugin/, url
    end

    test '#documentation_url and new docs page' do
      url = documentation_url('TestSection', type: 'plugin_manual', name: 'foreman_my_plugin', version: '1.2')

      assert_match %r{links/plugin_manual/TestSection\?name=foreman_my_plugin&version=1\.2}, url
    end

    test '#documentation_url and new docs page' do
      url = documentation_url('TestSection', type: 'docs', chapter: 'test_chapter')

      assert_match %r{links/docs/TestSection\?chapter=test_chapter}, url
    end

    test '#documentation_button forwards options to #documentation_url' do
      expects(:icon_text).returns('http://nowhere.com')
      expects(:link_to).returns('<a>test</a>'.html_safe)
      expects(:documentation_url).with('2.2PluginSection', :root_url => 'http://www.theforeman.org/my_plugin/v0.1/index.html#')

      documentation_button '2.2PluginSection', :root_url => 'http://www.theforeman.org/my_plugin/v0.1/index.html#'
    end

    test '#documentation_button forwards plugin manual options to #documentation_url' do
      expects(:icon_text).returns('http://nowhere.com')
      expects(:link_to).returns('<a>test</a>'.html_safe)
      expects(:documentation_url).with('2.2PluginSection', type: 'plugin_manual', name: 'foreman_my_plugin', version: '1.2')

      documentation_button '2.2PluginSection', type: 'plugin_manual', name: 'foreman_my_plugin', version: '1.2'
    end
  end

  describe 'accessible resources' do
    setup do
      permission = Permission.find_by_name('view_domains')
      filter = FactoryBot.create(:filter, :on_name_starting_with_a,
        :permissions => [permission])
      @user = FactoryBot.create(:user)
      @user.update_attribute :roles, [filter.role]
      @domain1 = FactoryBot.create(:domain, :name => 'a-domain.to-be-found.com')
      @domain2 = FactoryBot.create(:domain, :name => 'domain-not-to-be-found.com')
    end

    test "accessible_resource_records returns only authorized records" do
      as_user @user do
        records = accessible_resource_records(:domain)
        assert records.include? @domain1
        refute records.include? @domain2
      end
    end

    test "accessible_resource includes current value even if not authorized" do
      host = FactoryBot.create(:host, :domain => @domain2)
      domain3 = FactoryBot.create(:domain, :name => 'one-more-not-to-be-found.com')
      as_user @user do
        resources = accessible_resource(host, :domain)
        assert resources.include? @domain1
        assert resources.include? @domain2
        refute resources.include? domain3
      end
    end

    test "accessible_related_resource shows only authorized related records" do
      permission = Permission.find_by_name('view_subnets')
      filter = FactoryBot.create(:filter, :on_name_starting_with_a,
        :permissions => [permission])
      @user.roles << filter.role
      subnet1 = FactoryBot.create(:subnet_ipv4, :name => 'a subnet', :domains => [@domain1])
      subnet2 = FactoryBot.create(:subnet_ipv4, :name => 'some other subnet', :domains => [@domain1])
      subnet3 = FactoryBot.create(:subnet_ipv4, :name => 'a subnet in anoter domain', :domains => [@domain2])
      as_user @user do
        resources = accessible_related_resource(@domain1, :subnets)
        assert resources.include? subnet1
        refute resources.include? subnet2
        refute resources.include? subnet3
      end
    end
  end

  describe 'link_to generate valid links and anchors' do
    test 'test if having a javascript as a path crashes link_to' do
      assert_equal(link_to('link', 'javascript:foo()', class: 'btn'),
        '<a class="btn" href="javascript:foo()">link</a>')
    end
  end

  describe 'host details ui path generation' do
    setup do
      Setting[:host_details_ui] = true
      @host = FactoryBot.create(:host, :name => 'test-host')
    end

    test 'current_host_details_path generates path with host name when present' do
      result = current_host_details_path(@host)
      assert_equal "/new/hosts/#{@host.name}", result
    end

    test 'current_host_details_path falls back to host id for host without a name' do
      @host.name = ''

      result = current_host_details_path(@host)
      assert_equal "/new/hosts/#{@host.id}", result
    end
  end

  describe 'app_metadata and evaluate_metadata_hash' do
    test 'app_metadata returns hash with core and plugin metadata' do
      result = app_metadata

      assert_kind_of Hash, result
      assert result.key?(:version)
      assert result.key?(:UISettings)
    end

    test 'app_metadata evaluates lambda values in plugin metadata' do
      counter = 0
      ::Foreman::Plugin.app_metadata_registry.register(:test_plugin, {
        dynamic: -> { counter += 1 },
      })

      metadata = app_metadata
      result1 = metadata['test_plugin']['dynamic']
      result2 = app_metadata['test_plugin']['dynamic']

      assert_equal 1, result1
      assert_equal 2, result2
    ensure
      # Clean up test registration
      ::Foreman::Plugin.app_metadata_registry.instance_variable_get(:@plugin_metadata).delete(:test_plugin)
    end

    test 'app_metadata preserves static values' do
      ::Foreman::Plugin.app_metadata_registry.register(:test_plugin_static, {
        static_string: 'test',
        static_number: 42,
        static_bool: true,
      })

      result = app_metadata['test_plugin_static']

      assert_equal 'test', result['static_string']
      assert_equal 42, result['static_number']
      assert_equal true, result['static_bool']
    ensure
      ::Foreman::Plugin.app_metadata_registry.instance_variable_get(:@plugin_metadata).delete(:test_plugin_static)
    end

    test 'app_metadata handles mixed static and lambda values' do
      call_count = 0
      ::Foreman::Plugin.app_metadata_registry.register(:test_plugin_mixed, {
        static: 'static_value',
        dynamic: lambda {
                   call_count += 1
                   "dynamic_#{call_count}"
                 },
      })

      result = app_metadata['test_plugin_mixed']

      assert_equal 'static_value', result['static']
      assert_equal 'dynamic_1', result['dynamic']

      # Second call should re-evaluate lambda
      result2 = app_metadata['test_plugin_mixed']
      assert_equal 'dynamic_2', result2['dynamic']
    ensure
      ::Foreman::Plugin.app_metadata_registry.instance_variable_get(:@plugin_metadata).delete(:test_plugin_mixed)
    end
  end

  describe 'action_buttons' do
    test 'returns nil when no arguments provided' do
      result = action_buttons
      assert_nil result
    end

    test 'returns single button' do
      result = action_buttons('Edit')
      assert_match /Edit/, result
      assert_match /<span.*btn/, result
    end

    test 'returns single button from hash' do
      result = action_buttons({ content: 'Edit' })
      assert_match /Edit/, result
      assert_match /<span.*btn/, result
    end

    test 'returns dropdown for multiple buttons' do
      result = action_buttons('Edit', 'Delete', 'Clone')
      assert_match /btn-group/, result
      assert_match /dropdown-menu/, result
      assert_match /dropdown-toggle/, result
    end

    test 'renders dropdown for multiple buttons from hash' do
      items = [
        { content: 'Edit', options: { class: 'primary' } },
        { content: 'Delete', options: { class: 'danger' } },
        { content: 'Clone', options: { class: 'warning' } },
      ]
      result = action_buttons(*items)
      assert_match /btn-group/, result
      assert_match /<li class="danger">Delete<\/li>/, result
      assert_match /<li class="warning">Clone<\/li>/, result
    end
  end
end
