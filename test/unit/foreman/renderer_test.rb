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
      @renderer.host = FactoryBot.build_stubbed(:host)
      @renderer.send :preseed_attributes
      assert_nil @renderer.instance_variable_get('@preseed_path')
      assert_nil @renderer.instance_variable_get('@preseed_server')
    end

    test "set @preseed_server and @preseed_path if @host has medium and os" do
      host = FactoryBot.build_stubbed(:host, :managed)
      architecture = FactoryBot.build_stubbed(:architecture)
      medium = FactoryBot.build_stubbed(:medium, :path => 'http://my-example.com/my_path')
      os = FactoryBot.build_stubbed(:debian7_0, :media => [ medium ])
      host.architecture = architecture
      host.operatingsystem = os
      host.medium = medium
      @renderer.host = host
      @renderer.send :preseed_attributes
      assert_equal @renderer.instance_variable_get('@preseed_path'), '/my_path'
      assert_equal @renderer.instance_variable_get('@preseed_server'), 'my-example.com:80'
    end
  end

  describe "yast_attributes" do
    test "does not fail if @host does not have medium" do
      @renderer.host = FactoryBot.build_stubbed(:host)
      @renderer.send :yast_attributes
      assert_nil @renderer.instance_variable_get('@mediapath')
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

  test "foreman_url should respect proxy with Templates feature" do
    host = FactoryBot.build(:host, :with_separate_provision_interface, :with_dhcp_orchestration)
    host.provision_interface.subnet.template = FactoryBot.build(:template_smart_proxy)
    ProxyAPI::Template.any_instance.stubs(:template_url).returns(host.provision_interface.subnet.template.url)
    @renderer.host = host
    assert_match(host.provision_interface.subnet.template.url, @renderer.foreman_url)
  end

  test "foreman_url should run with @host as nil" do
    assert_nothing_raised { @renderer.foreman_url }
  end

  test "pxe_kernel_options are not set when no OS is set" do
    @renderer.host = FactoryBot.build_stubbed(:host)
    assert_equal '', @renderer.pxe_kernel_options
  end

  test "pxe_kernel_options returns blacklist option for Red Hat" do
    host = FactoryBot.build_stubbed(:host, :operatingsystem => Operatingsystem.find_by_name('Redhat'))
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

    test "#{renderer_name} should raise renderer syntax error on syntax error" do
      send "setup_#{renderer_name}"
      template = <<EOS
line 1: ok
line 2: ok
line 3: <%= 1 + %>
line 4: ok
EOS
      @renderer.instance_variable_set '@template_name', 'my_template'
      exception = assert_raises Foreman::Renderer::SyntaxError do
        @renderer.render_safe(template, [], {})
      end
      if renderer_name == :normal_renderer
        assert_include exception.message, 'my_template:3' if ERB.method_defined?(:location=)
        assert_include exception.message, "syntax error, unexpected ')'"
      else
        assert_include exception.message, 'parse error on value ")"'
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

    test "global_setting helper method" do
      send "setup_#{renderer_name}"
      Setting[:default_pxe_item_global] = "PASS"
      tmpl = @renderer.render_safe('<%= global_setting("default_pxe_item_global") %>', [:global_setting])
      assert_equal 'PASS', tmpl
    end

    test "global_setting helper method with special case 'false'" do
      send "setup_#{renderer_name}"
      Setting[:default_pxe_item_global] = false
      tmpl = @renderer.render_safe('<%= global_setting("default_pxe_item_global") %>', [:global_setting])
      assert_equal '', tmpl
    end

    test "global_setting helper method with symbol" do
      send "setup_#{renderer_name}"
      Setting[:default_pxe_item_global] = "PASS"
      tmpl = @renderer.render_safe('<%= global_setting(:default_pxe_item_global) %>', [:global_setting])
      assert_equal 'PASS', tmpl
    end

    test "global_setting helper method with own default" do
      send "setup_#{renderer_name}"
      Setting[:default_pxe_item_global] = ""
      tmpl = @renderer.render_safe('<%= global_setting("default_pxe_item_global", "PASS") %>', [:global_setting])
      assert_equal 'PASS', tmpl
    end

    test "global_setting helper default does not work with boolean" do
      send "setup_#{renderer_name}"
      Setting[:update_ip_from_built_request] = false
      assert_equal "boolean", Setting.find_by_name("update_ip_from_built_request").settings_type
      tmpl = @renderer.render_safe('<%= global_setting("update_ip_from_built_request", "FAIL").to_s %>', [:global_setting])
      assert_equal 'false', tmpl
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
      snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "A <%= @b + ' ' + @c -%> D")
      tmpl = @renderer.snippet(snippet.name, :variables => { :b => 'B', :c => 'C' })
      assert_equal 'A B C D', tmpl
    end

    test "#{renderer_name} should render a snippet_if_exists with variables" do
      send "setup_#{renderer_name}"
      snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "A <%= @b + ' ' + @c -%> D")
      tmpl = @renderer.snippet_if_exists(snippet.name, :variables => { :b => 'B', :c => 'C' })
      assert_equal 'A B C D', tmpl
    end

    test "#{renderer_name} should render a snippets with variables" do
      send "setup_#{renderer_name}"
      snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "A <%= @b + ' ' + @c -%> D")
      tmpl = @renderer.snippets(snippet.name, :variables => { :b => 'B', :c => 'C' })
      assert_equal 'A B C D', tmpl
    end

    test "#{renderer_name} should render a save_to_file macro" do
      assert_renders('<%= save_to_file("/etc/puppet/puppet.conf", "[main]\nserver=example.com\n") %>', "cat << EOF > /etc/puppet/puppet.conf\n[main]\nserver=example.com\nEOF", nil)
    end

    test "#{renderer_name} should define passed variables only in snippet scope" do
      send "setup_#{renderer_name}"
      level2_snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "<%= @level2 -%>")
      level1_snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "<%= @level1 -%><%= snippet('#{level2_snippet.name}', :variables => {:level2 => 2}) %><%= @level2 %>")
      tmpl = @renderer.render_safe("<%= snippet('#{level1_snippet.name}', :variables => {:level1 => 1}) -%><%= @level1 %>", [:snippet])

      assert_equal '12', tmpl
    end

    test "#{renderer_name} should render a templates_used" do
      send "setup_#{renderer_name}"
      @renderer.host = FactoryBot.build_stubbed(
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
      host = FactoryBot.create(:host)
      send "setup_#{renderer_name}"
      tmpl = @renderer.render_safe("<% @host.managed_interfaces.each do |int| -%><%= int.to_s -%><% end -%>", [], { :host => host })
      assert_equal host.name, tmpl
    end

    test "#{renderer_name} should render with AR collection proxy method calls" do
      host = FactoryBot.create(:host)
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
    @renderer.host = FactoryBot.build(:host, :with_puppetclass)
    assert @renderer.host_puppet_classes
  end

  test 'should render host param using "host_param" helper' do
    @renderer.host = FactoryBot.build(:host, :with_puppet)
    assert @renderer.host_param('test').present?
  end

  test 'should render host param using "host_param" helper for not existing parameter' do
    @renderer.host = FactoryBot.build(:host, :with_puppet)
    assert_nil @renderer.host_param('not_existing_param')
  end

  test 'should render host param using "host_param" helper for not existing parameter using default value' do
    @renderer.host = FactoryBot.build(:host, :with_puppet)
    assert_equal 42, @renderer.host_param('not_existing_param', 42)
  end

  test 'should raise rendering exception if @host is not set while rendering @host based macros' do
    @renderer.host = nil
    assert_raises(Foreman::Renderer::HostUnknown) do
      @renderer.host_param('test')
    end
  end

  test 'should raise rendering exception if host_param! is used for not existing param' do
    @renderer.host = FactoryBot.build(:host, :with_puppet)
    assert_raises(Foreman::Renderer::HostParamUndefined) do
      @renderer.host_param!('not_existing_param')
    end
  end

  test 'should have host_param_true? helper' do
    @renderer.host = FactoryBot.create(:host, :with_puppet)
    FactoryBot.create(:parameter, :name => 'true_param', :value => "true")
    assert @renderer.host_param_true?('true_param')
  end

  test 'should have host_param_false? helper' do
    @renderer.host = FactoryBot.create(:host, :with_puppet)
    FactoryBot.create(:parameter, :name => 'false_param', :value => "false")
    assert @renderer.host_param_false?('false_param')
  end

  context 'subnet helpers' do
    setup do
      @renderer.host = FactoryBot.build(:host, :with_puppet)
      subnets(:one).subnet_parameters.create(name: 'myparam', value: 'myvalue')
    end

    test 'should have subnet_has_param? helper returning true' do
      assert @renderer.subnet_has_param?(subnets(:one), 'myparam')
    end

    test 'should have subnet_has_param? helper returning false' do
      refute @renderer.subnet_has_param?(subnets(:one), 'my_wrong_param')
    end

    test 'should have subnet_has_param? helper returning false when subnet is nil' do
      assert_raises Foreman::Renderer::WrongSubnetError do
        @renderer.subnet_has_param?(nil, 'myparam')
      end
    end

    test 'should render existing subnet param using "subnet_param" helper' do
      assert_equal @renderer.subnet_param(subnets(:one), 'myparam'), 'myvalue'
    end

    test 'should not render missing subnet param using "subnet_param" helper' do
      assert_nil @renderer.subnet_param(subnets(:one), 'my_wrong_param')
    end

    test 'should throw an error using "subnet_param" helper with nil' do
      assert_raises Foreman::Renderer::WrongSubnetError do
        @renderer.subnet_param(nil, 'myparam')
      end
    end
  end

  test 'should have host_enc helper' do
    @renderer.host = FactoryBot.build(:host, :with_puppet)
    assert @renderer.host_enc
  end

  test "should find path in host_enc" do
    host = FactoryBot.build(:host, :with_puppet)
    @renderer.host = host
    assert_equal host.puppetmaster, @renderer.host_enc('parameters', 'puppetmaster')
  end

  test "should raise rendering exception if no such parameter exists while rendering host_enc" do
    host = FactoryBot.build(:host, :with_puppet)
    @renderer.host = host
    assert_raises(Foreman::Renderer::HostENCParamUndefined) do
      assert_equal host.puppetmaster, @renderer.host_enc('parameters', 'puppetmaster_that_does_not_exist')
    end
  end

  test 'should raise rendering exception if @host is not set while rendering host_enc' do
    @renderer.host = nil
    assert_raises(Foreman::Renderer::HostUnknown) do
      @renderer.host_enc('parameters', 'puppetmaster')
    end
  end

  test 'templates_used is allowed to render for host' do
    assert Safemode.find_jail_class(Host::Managed).allowed? :templates_used
  end

  test "global_setting unsafe attempt" do
    assert_raises(Foreman::Renderer::FilteredGlobalSettingAccessed) do
      setup_safemode_renderer
      @renderer.render_safe('<%= global_setting("not_allowed_setting") %>', [:global_setting])
    end
  end

  private

  def assert_renders(template_content, output, host)
    @renderer.host = host
    template = mock('template')
    template.stubs(:template).returns(template_content)
    assert_nothing_raised do
      content = @renderer.unattended_render(template)
      assert_equal(output, content)
    end
  end
end
