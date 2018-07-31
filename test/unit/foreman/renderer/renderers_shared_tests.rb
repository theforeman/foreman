module RenderersSharedTests
  extend ActiveSupport::Concern

  included do
    setup do
      @host = FactoryBot.create(:host, architecture: FactoryBot.create(:architecture, :name => 'SPARC-T2'),
                                       operatingsystem: operatingsystems(:redhat))
      @scope = Class.new(Foreman::Renderer::Scope::Base) do
        include Foreman::Renderer::Scope::Macros::Base
        include Foreman::Renderer::Scope::Macros::SnippetRendering
      end.send(:new, host: @host)
    end

    test "should evaluate template variables" do
      source = OpenStruct.new(content: '<%= @host.name %>')
      assert_equal @host.name, renderer.render(source, @scope)
    end

    test "should evaluate renderer methods" do
      @scope.expects(:foreman_url).returns('bar')
      source = OpenStruct.new(content: '<%= foreman_url %>')
      assert_equal 'bar', renderer.render(source, @scope)
    end

    test "foreman_server_fqdn helper method" do
      source = OpenStruct.new(content: '<%= foreman_server_fqdn %>')
      assert_equal 'foreman.some.host.fqdn', renderer.render(source, @scope)
    end

    test "foreman_server_url helper method" do
      source = OpenStruct.new(content: '<%= foreman_server_url %>')
      assert_equal 'http://foreman.some.host.fqdn', renderer.render(source, @scope)
    end

    test "indent helper method" do
      source = OpenStruct.new(content: '<%= indent(3) { "test" } %>')
      assert_equal '   test', renderer.render(source, @scope)
    end

    test "global_setting helper method" do
      source = OpenStruct.new(content: '<%= global_setting("default_pxe_item_global") %>')
      Setting[:default_pxe_item_global] = "PASS"
      assert_equal 'PASS', renderer.render(source, @scope)
    end

    test "global_setting helper method with special case 'false'" do
      source = OpenStruct.new(content: '<%= global_setting("default_pxe_item_global") %>')
      Setting[:default_pxe_item_global] = false
      assert_equal '', renderer.render(source, @scope)
    end

    test "global_setting helper method with symbol" do
      source = OpenStruct.new(content: '<%= global_setting("default_pxe_item_global") %>')
      Setting[:default_pxe_item_global] = "PASS"
      assert_equal 'PASS', renderer.render(source, @scope)
    end

    test "global_setting helper method with own default" do
      source = OpenStruct.new(content: '<%= global_setting("default_pxe_item_global", "PASS") %>')
      Setting[:default_pxe_item_global] = ""
      assert_equal 'PASS', renderer.render(source, @scope)
    end

    test "global_setting helper default does not work with boolean" do
      source = OpenStruct.new(content: '<%= global_setting("update_ip_from_built_request", "FAIL").to_s %>')
      Setting[:update_ip_from_built_request] = false
      assert_equal "boolean", Setting.find_by_name("update_ip_from_built_request").settings_type
      assert_equal 'false', renderer.render(source, @scope)
    end

    test "dns_lookup helper method - address" do
      source = OpenStruct.new(content: '<%= dns_lookup("test.domain.com") %>')
      Resolv::DNS.any_instance.expects(:getaddress).with("test.domain.com").returns("1.2.3.4")
      assert_equal "1.2.3.4", renderer.render(source, @scope)
    end

    test "dns_lookup helper method - hostname" do
      source = OpenStruct.new(content: '<%= dns_lookup("1.2.3.4") %>')
      Resolv::DNS.any_instance.expects(:getname).with("1.2.3.4").returns("test.domain.com")
      assert_equal "test.domain.com", renderer.render(source, @scope)
    end

    test "dns_lookup helper method - invalid IPv4" do
      source = OpenStruct.new(content: '<%= dns_lookup("1.2.3.999") %>')
      Resolv::DNS.any_instance.expects(:getaddress).with("1.2.3.999").returns("xxx")
      assert_equal "xxx", renderer.render(source, @scope)
    end

    test "should define passed variables only in snippet scope" do
      level2_snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "<%= @level2 -%>")
      level1_snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "<%= @level1 -%><%= snippet('#{level2_snippet.name}', :variables => {:level2 => 2}) %><%= @level2 %>")
      source = OpenStruct.new(content: "<%= snippet('#{level1_snippet.name}', :variables => {:level1 => 1}) -%><%= @level1 %>")
      assert_equal '12', renderer.render(source, @scope)
    end

    test "should render a save_to_file macro" do
      source = OpenStruct.new(content: '<%= save_to_file("/etc/puppet/puppet.conf", "[main]\nserver=example.com\n") %>')
      assert_nothing_raised do
        assert_equal("cat << EOF > /etc/puppet/puppet.conf\n[main]\nserver=example.com\nEOF", renderer.render(source, @scope))
      end
    end

    test "should render a templates_used" do
      source = OpenStruct.new(content: '<%= @host.templates_used %>')
      assert_nothing_raised do
        content = renderer.render(source, @scope)
        assert_match(/#{@host.provisioning_template(:kind => 'provision')}/, content)
        assert_match(/#{@host.provisioning_template(:kind => 'script')}/, content)
      end
    end

    test "should render template name" do
      source = OpenStruct.new(name: 'abc', content: 'x <%= @template_name %> <%= template_name %>')
      assert_equal 'x abc abc', renderer.render(source, @scope)
    end

    test "should render with AR relation method calls" do
      source = OpenStruct.new(content: "<% @host.managed_interfaces.each do |int| -%><%= int.to_s -%><% end -%>")
      assert_equal @host.name, renderer.render(source, @scope)
    end

    test "should render with AR collection proxy method calls" do
      source = OpenStruct.new(content: "<% @host.interfaces.each do |int| -%><%= int.to_s -%><% end -%>")
      assert_equal @host.name, renderer.render(source, @scope)
    end

    test "global_setting unsafe attempt" do
      source = OpenStruct.new(content: '<%= global_setting("not_allowed_setting") %>')
      assert_raises(Foreman::Renderer::Errors::FilteredGlobalSettingAccessed) do
        renderer.render(source, @scope)
      end
    end

    test "should raise SyntaxError" do
      source = OpenStruct.new(content: '<%- begin %>')
      assert_raises(Foreman::Renderer::Errors::SyntaxError) do
        renderer.render(source, @scope)
      end
    end

    test "should load hosts" do
      source = OpenStruct.new(content: '<%= load_hosts.map { |b| b.size }.inject(0) { |m,c| m += c } %>')
      assert_equal(renderer.render(source, @scope), Host.count.to_s)
    end

    test "should find all registered host statuses" do
      source = OpenStruct.new(content: '<%= all_host_statuses.map { |s| s.status_name }.join(",") %>')
      assert_equal(renderer.render(source, @scope), "Build,Configuration")
    end
  end
end
