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
      url = documentation_url('TestSection', { type: 'docs', chapter: 'test_chapter' })

      assert_match /links\/docs/, url
      assert_match /chapter=test_chapter/, url
      assert_match /section=TestSection/, url
    end

    test '#documentation_button forwards options to #documentation_url' do
      expects(:icon_text).returns('http://nowhere.com')
      expects(:link_to).returns('<a>test</a>'.html_safe)
      expects(:documentation_url).with('2.2PluginSection', { :root_url => 'http://www.theforeman.org/my_plugin/v0.1/index.html#' })

      documentation_button '2.2PluginSection', :root_url => 'http://www.theforeman.org/my_plugin/v0.1/index.html#'
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
end
