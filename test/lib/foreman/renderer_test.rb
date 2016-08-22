require 'test_helper'
require 'foreman/renderer'

class RendererTest < ActiveSupport::TestCase
  include Foreman::Renderer

  def setup_normal_renderer
    Setting[:safemode_render] = false
  end

  def setup_safemode_renderer
    Setting[:safemode_render] = true
  end

  test "foreman_url should run with @host as nil" do
    @host = nil
    self.expects(:url_for).returns("url")
    assert_nothing_raised(NoMethodError) { foreman_url }
  end

  [:normal_renderer, :safemode_renderer].each do |renderer_name|
    test "#{renderer_name} is properly configured" do
      send "setup_#{renderer_name}"
      if renderer_name == :normal_renderer
        assert Setting[:safemode_render] == false
      else
        assert Setting[:safemode_render] == true
      end
    end

    test "#{renderer_name} should evaluate template variables" do
      send "setup_#{renderer_name}"
      tmpl = render_safe('<%= @foo %>', [], { :foo => 'bar' })
      assert_equal 'bar', tmpl
    end

    test "#{renderer_name} should evaluate renderer methods" do
      send "setup_#{renderer_name}"
      self.expects(:foreman_url).returns('bar')
      tmpl = render_safe('<%= foreman_url %>', [:foreman_url])
      assert_equal 'bar', tmpl
    end

    test "foreman_server_fqdn helper method" do
      send "setup_#{renderer_name}"
      tmpl = render_safe('<%= foreman_server_fqdn %>', [:foreman_server_fqdn])
      assert_equal 'foreman.some.host.fqdn', tmpl
    end

    test "foreman_server_url helper method" do
      send "setup_#{renderer_name}"
      tmpl = render_safe('<%= foreman_server_url %>', [:foreman_server_url])
      assert_equal 'http://foreman.some.host.fqdn', tmpl
    end

    test "indent helper method" do
      send "setup_#{renderer_name}"
      tmpl = render_safe('<%= indent(3) { "test" } %>', [:indent])
      assert_equal '   test', tmpl
    end

    test "dns_lookup helper method - address" do
      send "setup_#{renderer_name}"
      Resolv::DNS.any_instance.expects(:getaddress).with("test.domain.com").returns("1.2.3.4")
      tmpl = render_safe('<%= dns_lookup("test.domain.com") %>', [:dns_lookup])
      assert_equal "1.2.3.4", tmpl
    end

    test "dns_lookup helper method - hostname" do
      send "setup_#{renderer_name}"
      Resolv::DNS.any_instance.expects(:getname).with("1.2.3.4").returns("test.domain.com")
      tmpl = render_safe('<%= dns_lookup("1.2.3.4") %>', [:dns_lookup])
      assert_equal "test.domain.com", tmpl
    end

    test "dns_lookup helper method - invalid IPv4" do
      send "setup_#{renderer_name}"
      Resolv::DNS.any_instance.expects(:getaddress).with("1.2.3.999").returns("xxx")
      tmpl = render_safe('<%= dns_lookup("1.2.3.999") %>', [:dns_lookup])
      assert_equal "xxx", tmpl
    end

    test "#{renderer_name} should render a snippet" do
      send "setup_#{renderer_name}"
      snippet = mock("snippet")
      snippet.stubs(:name).returns("test")
      snippet.stubs(:template).returns("content")
      Template.expects(:where).with(:name => "test", :snippet => true).returns([snippet])
      tmpl = snippet('test')
      assert_equal 'content', tmpl
    end

    test "#{renderer_name} should not raise error when snippet is not found" do
      send "setup_#{renderer_name}"
      Template.expects(:where).with(:name => "test", :snippet => true).returns([])
      assert_nil snippet_if_exists('test')
    end

    test "#{renderer_name} should render unnamed template" do
      send "setup_#{renderer_name}"
      tmpl = unattended_render('x <%= @template_name %> <%= template_name %>')
      assert_equal 'x Unnamed Unnamed', tmpl
    end

    test "#{renderer_name} should render template name" do
      send "setup_#{renderer_name}"
      template = mock('template')
      template.stubs(:template).returns('x <%= @template_name %> <%= template_name %>')
      template.stubs(:name).returns('abc')
      tmpl = unattended_render(template)
      assert_equal 'x abc abc', tmpl
    end

    test "#{renderer_name} should render with AR relation method calls" do
      host = FactoryGirl.create(:host)
      send "setup_#{renderer_name}"
      tmpl = render_safe("<% @host.managed_interfaces.each do |int| -%><%= int.to_s -%><% end -%>", [], { :host => host })
      assert_equal host.name, tmpl
    end

    test "#{renderer_name} should render with AR collection proxy method calls" do
      host = FactoryGirl.create(:host)
      send "setup_#{renderer_name}"
      tmpl = render_safe("<% @host.interfaces.each do |int| -%><%= int.to_s -%><% end -%>", [], { :host => host })
      assert_equal host.name, tmpl
    end

    test "#{renderer_name} should error out when template was not found" do
      send "setup_#{renderer_name}"
      ex = assert_raises Foreman::Exception do
        unattended_render(nil)
      end
      assert_match(/is either missing or has an invalid organization or location/, ex.message)
    end
  end

  test 'ActiveRecord::AssociationRelation jail test' do
    allowed = [:[], :each, :first, :to_a]
    allowed.each do |m|
      assert ActiveRecord::AssociationRelation::Jail.allowed?(m), "Method #{m} is not available in ActiveRecord::AssociationRelation::Jail while should be allowed."
    end
  end

  test 'ActiveRecord::Associations::CollectionProxy jail test' do
    allowed = [:[], :each, :first, :to_a]
    allowed.each do |m|
      assert ActiveRecord::AssociationRelation::Jail.allowed?(m), "Method #{m} is not available in ActiveRecord::Associations::CollectionProxy::Jail while should be allowed."
    end
  end

  test '#allowed_variables_mapping loads instance variables' do
    @whatever_random_name = 'has_value'
    assert_equal({ :whatever_random_name => 'has_value' }, allowed_variables_mapping([ :whatever_random_name ]))
  end
end
