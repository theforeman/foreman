require 'test_helper'

class RendererTest < ActiveSupport::TestCase
  class DummyRenderer
    attr_accessor :host

    include Foreman::Renderer
  end

  class RendererWithOwnDefaultUrlOptions
    attr_accessor :host

    include Foreman::Renderer

    def default_url_options
      { :host => 'example.com' }
    end
  end

  setup do
    @renderer = DummyRenderer.new
  end

  test "should indent a string" do
    indented = @renderer.indent 4 do
      "foo\nbar\nbaz"
    end
    assert_equal indented, "    foo\n    bar\n    baz"
  end

  describe "preseed_attributes" do
    test "do not set @preseed_server and @preseed_path if @host does not have medium and os" do
      @renderer.host = FactoryGirl.build(:host)
      @renderer.send :preseed_attributes
      assert_nil @renderer.instance_variable_get('@preseed_path')
      assert_nil @renderer.instance_variable_get('@preseed_server')
    end

    test "set @preseed_server and @preseed_path if @host has medium and os" do
      host = FactoryGirl.build(:host, :managed)
      architecture = FactoryGirl.build(:architecture)
      medium = FactoryGirl.build(:medium, :path => 'http://my-example.com/my_path')
      os = FactoryGirl.build(:debian7_0, :media => [ medium ])
      host.architecture = architecture
      host.operatingsystem = os
      host.medium = medium
      @renderer.host = host
      @renderer.send :preseed_attributes
      assert_equal @renderer.instance_variable_get('@preseed_path'), '/my_path'
      assert_equal @renderer.instance_variable_get('@preseed_server'), 'my-example.com:80'
    end
  end

  test '#foreman_url can be rendered even outside of controller context' do
    assert_nothing_raised do
      assert_match /\/unattended\/built/, @renderer.foreman_url('built')
    end
  end

  test '#default_url_options is overriden only if it is not defined' do
    renderer = RendererWithOwnDefaultUrlOptions.new
    url = renderer.url_for :only_path => false, :controller => 'hosts', :action => 'index'
    assert_includes url, 'example.com'
  end

  def setup_normal_renderer
    Setting[:safemode_render] = false
  end

  def setup_safemode_renderer
    Setting[:safemode_render] = true
  end

  test "foreman_url should run with @host as nil" do
    assert_nothing_raised(NoMethodError) { @renderer.foreman_url }
  end

  test "pxe_kernel_options are not set when no OS is set" do
    @renderer.host = FactoryGirl.build(:host)
    assert_equal '', @renderer.pxe_kernel_options
  end

  test "pxe_kernel_options returns blacklist option for Red Hat" do
    host = FactoryGirl.build(:host, :operatingsystem => Operatingsystem.find_by_name('Redhat'))
    host.params['blacklist'] = 'dirty_driver, badbad_driver'
    @renderer.host = host
    assert_equal 'modprobe.blacklist=dirty_driver,badbad_driver', @renderer.pxe_kernel_options
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
      tmpl = @renderer.render_safe('<%= @foo %>', [], { :foo => 'bar' })
      assert_equal 'bar', tmpl
    end

    test "#{renderer_name} should evaluate renderer methods" do
      send "setup_#{renderer_name}"
      @renderer.expects(:foreman_url).returns('bar')
      tmpl = @renderer.render_safe('<%= foreman_url %>', [:foreman_url])
      assert_equal 'bar', tmpl
    end

    test "foreman_server_fqdn helper method" do
      send "setup_#{renderer_name}"
      tmpl = @renderer.render_safe('<%= foreman_server_fqdn %>', [:foreman_server_fqdn])
      assert_equal 'foreman.some.host.fqdn', tmpl
    end

    test "foreman_server_url helper method" do
      send "setup_#{renderer_name}"
      tmpl = @renderer.render_safe('<%= foreman_server_url %>', [:foreman_server_url])
      assert_equal 'http://foreman.some.host.fqdn', tmpl
    end

    test "indent helper method" do
      send "setup_#{renderer_name}"
      tmpl = @renderer.render_safe('<%= indent(3) { "test" } %>', [:indent])
      assert_equal '   test', tmpl
    end

    test "dns_lookup helper method - address" do
      send "setup_#{renderer_name}"
      Resolv::DNS.any_instance.expects(:getaddress).with("test.domain.com").returns("1.2.3.4")
      tmpl = @renderer.render_safe('<%= dns_lookup("test.domain.com") %>', [:dns_lookup])
      assert_equal "1.2.3.4", tmpl
    end

    test "dns_lookup helper method - hostname" do
      send "setup_#{renderer_name}"
      Resolv::DNS.any_instance.expects(:getname).with("1.2.3.4").returns("test.domain.com")
      tmpl = @renderer.render_safe('<%= dns_lookup("1.2.3.4") %>', [:dns_lookup])
      assert_equal "test.domain.com", tmpl
    end

    test "dns_lookup helper method - invalid IPv4" do
      send "setup_#{renderer_name}"
      Resolv::DNS.any_instance.expects(:getaddress).with("1.2.3.999").returns("xxx")
      tmpl = @renderer.render_safe('<%= dns_lookup("1.2.3.999") %>', [:dns_lookup])
      assert_equal "xxx", tmpl
    end

    test "#{renderer_name} should render a snippet" do
      send "setup_#{renderer_name}"
      snippet = mock("snippet")
      snippet.stubs(:name).returns("test")
      snippet.stubs(:template).returns("content")
      Template.expects(:where).with(:name => "test", :snippet => true).returns([snippet])
      tmpl = @renderer.snippet('test')
      assert_equal 'content', tmpl
    end

    test "#{renderer_name} should render a snippet with variables" do
      send "setup_#{renderer_name}"
      snippet = FactoryGirl.create(:provisioning_template, :snippet, :template => "A <%= @b + ' ' + @c -%> D")
      tmpl = @renderer.snippet(snippet.name, :variables => { :b => 'B', :c => 'C' })
      assert_equal 'A B C D', tmpl
    end

    test "#{renderer_name} should render a templates_used" do
      send "setup_#{renderer_name}"
      @renderer.host = FactoryGirl.build(
        :host,
        :operatingsystem => operatingsystems(:redhat)
      )
      template = mock('template')
      template.stubs(:template).returns('<%= @host.templates_used %>')
      assert_nothing_raised do
        content = @renderer.unattended_render(template)
        assert_match(/#{@renderer.host.provisioning_template(:kind => 'provision')}/, content)
        assert_match(/#{@renderer.host.provisioning_template(:kind => 'script')}/, content)
      end
    end

    test "#{renderer_name} should not raise error when snippet is not found" do
      send "setup_#{renderer_name}"
      Template.expects(:where).with(:name => "test", :snippet => true).returns([])
      assert_nil @renderer.snippet_if_exists('test')
    end

    test "#{renderer_name} should render unnamed template" do
      send "setup_#{renderer_name}"
      tmpl = @renderer.unattended_render('x <%= @template_name %> <%= template_name %>')
      assert_equal 'x Unnamed Unnamed', tmpl
    end

    test "#{renderer_name} should render template name" do
      send "setup_#{renderer_name}"
      template = mock('template')
      template.stubs(:template).returns('x <%= @template_name %> <%= template_name %>')
      template.stubs(:name).returns('abc')
      tmpl = @renderer.unattended_render(template)
      assert_equal 'x abc abc', tmpl
    end

    test "#{renderer_name} should render with AR relation method calls" do
      host = FactoryGirl.create(:host)
      send "setup_#{renderer_name}"
      tmpl = @renderer.render_safe("<% @host.managed_interfaces.each do |int| -%><%= int.to_s -%><% end -%>", [], { :host => host })
      assert_equal host.name, tmpl
    end

    test "#{renderer_name} should render with AR collection proxy method calls" do
      host = FactoryGirl.create(:host)
      send "setup_#{renderer_name}"
      tmpl = @renderer.render_safe("<% @host.interfaces.each do |int| -%><%= int.to_s -%><% end -%>", [], { :host => host })
      assert_equal host.name, tmpl
    end

    test "#{renderer_name} should error out when template was not found" do
      send "setup_#{renderer_name}"
      ex = assert_raises Foreman::Exception do
        @renderer.unattended_render(nil)
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
    @renderer.instance_variable_set '@whatever_random_name', 'has_value'
    assert_equal({ :whatever_random_name => 'has_value' }, @renderer.send(:allowed_variables_mapping, [ :whatever_random_name ]))
  end

  test 'should render puppetclasses using host_puppetclasses helper' do
    @renderer.host = FactoryGirl.create(:host, :with_puppetclass)
    assert @renderer.host_puppet_classes
  end

  test 'should render host param using "host_param" helper' do
    @renderer.host = FactoryGirl.create(:host, :with_puppet)
    assert @renderer.host_param('test').present?
  end

  test 'should have host_param_true? helper' do
    @renderer.host = FactoryGirl.create(:host, :with_puppet)
    FactoryGirl.create(:parameter, :name => 'true_param', :value => "true")
    assert @renderer.host_param_true?('true_param')
  end

  test 'should have host_param_false? helper' do
    @renderer.host = FactoryGirl.create(:host, :with_puppet)
    FactoryGirl.create(:parameter, :name => 'false_param', :value => "false")
    assert @renderer.host_param_false?('false_param')
  end

  test 'should have host_enc helper' do
    @renderer.host = FactoryGirl.create(:host, :with_puppet)
    assert @renderer.host_enc
  end

  test "should find path in host_enc" do
    host = FactoryGirl.create(:host, :with_puppet)
    @renderer.host = host
    assert_equal host.puppetmaster, @renderer.host_enc('parameters', 'puppetmaster')
  end

  test 'templates_used is allowed to render for host' do
    assert Safemode.find_jail_class(Host::Managed).allowed? :templates_used
  end
end
