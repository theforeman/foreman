module RenderersSharedTests
  extend ActiveSupport::Concern

  included do
    setup do
      @template = OpenStruct.new(
        name: 'abc',
        template: 'Test'
      )
      source = Foreman::Renderer::Source::Database.new(
        @template
      )
      @host = FactoryBot.create(:host, architecture: FactoryBot.create(:architecture, :name => 'SPARC-T2'),
                                       operatingsystem: operatingsystems(:redhat))
      @scope = Class.new(Foreman::Renderer::Scope::Base) do
        include Foreman::Renderer::Scope::Macros::Base
        include Foreman::Renderer::Scope::Macros::SnippetRendering
      end.send(:new, host: @host, source: source, variables: { x: 'test' })
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

    test "plugin_present? finds existing plugin" do
      Foreman::Plugin.register(:existing_plugin) {}
      source = OpenStruct.new(content: '<%= plugin_present?("existing_plugin") %>')
      assert_equal 'true', renderer.render(source, @scope)
    end

    test "plugin_present? does not find nonexistant plugin" do
      Foreman::Plugin.register(:existing_plugin) {}
      source = OpenStruct.new(content: '<%= plugin_present?("nonexisting_plugin") %>')
      assert_equal 'false', renderer.render(source, @scope)
    end

    test "rand_hex helper method" do
      source = OpenStruct.new(content: '<%= rand_hex(5) %>')
      assert_not_nil renderer.render(source, @scope)
    end

    test "rand_name helper method" do
      source = OpenStruct.new(content: '<%= rand_name %>')
      assert_not_nil renderer.render(source, @scope)
    end

    test "mac_name helper method" do
      source = OpenStruct.new(content: '<%= mac_name("52:54:00:3d:f3:53") %>')
      assert_equal 'jimmy-alton-danko-deckard', renderer.render(source, @scope)
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

    test "should pass variables from template to snippet" do
      snippet = FactoryBot.create(:provisioning_template, :snippet, :template => "<%= @x -%>")
      template = OpenStruct.new(content: "<%= snippet('#{snippet.name}') %>")

      assert_equal renderer.render(template, @scope), 'test'
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
      source = OpenStruct.new(name: @template.name, content: 'x <%= @template_name %> <%= template_name %>')
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
      statuses = renderer.render(source, @scope).split(',')

      assert_includes statuses, 'Build'
      assert_includes statuses, 'Configuration'
      assert(statuses.index('Build') < statuses.index('Configuration'))
    end

    test "should respect preview setting" do
      source = OpenStruct.new(content: 'id <%= preview? %>')

      assert_equal("id false", renderer.render(source, @scope))
      @scope.instance_variable_set '@mode', Foreman::Renderer::PREVIEW_MODE
      assert_equal("id true", renderer.render(source, @scope))
    end

    test "should compare versions correctly" do
      source = OpenStruct.new(content: '<%= gem_version_compare("10.2.3", "2.0.1") %>')
      assert_equal(renderer.render(source, @scope), '1')

      source = OpenStruct.new(content: '<%= gem_version_compare("1.2.3", "1.2.3") %>')
      assert_equal(renderer.render(source, @scope), '0')

      source = OpenStruct.new(content: '<%= gem_version_compare("1.2.3", "1.2.4") %>')
      assert_equal(renderer.render(source, @scope), '-1')
    end

    test "foreman_server_ca_cert - existing file" do
      cert_path = Rails.root.join('test/static_fixtures/certificates/example.com.crt')
      Setting[:ssl_ca_file] = cert_path
      source = OpenStruct.new(content: '<%= foreman_server_ca_cert %>')
      assert_equal(renderer.render(source, @scope), File.read(cert_path))
    end

    test "foreman_server_ca_cert - not existing file" do
      Setting[:ssl_ca_file] = 'not-existing-file'
      source = OpenStruct.new(content: '<%= foreman_server_ca_cert %>')
      error = assert_raise Foreman::Exception do
        renderer.render(source, @scope)
      end

      assert_includes error.message, '[Foreman::Exception]: No such file or directory'
    end

    test "foreman_server_ca_cert - blank setting" do
      Setting[:ssl_ca_file] = ''
      source = OpenStruct.new(content: '<%= foreman_server_ca_cert %>')
      error = assert_raise Foreman::Renderer::Errors::UndefinedSetting do
        renderer.render(source, @scope)
      end

      # assert_includes error.message, "No CA file set, check the 'SSL CA file' in Settings > Authentication"
      assert_includes error.message, "Undefined setting 'SSL CA file'"
    end

    context 'renderer for template with user input used' do
      let(:template) { FactoryBot.build(:provisioning_template, :template => 'service restart <%= input("service_name") -%>') }
      let(:source) { Foreman::Renderer::Source::Database.new(template) }
      let(:real_scope) { Foreman::Renderer::Scope::Provisioning.new(host: @host, source: source) }
      let(:preview_scope) { Foreman::Renderer::Scope::Provisioning.new(host: @host, source: source, mode: Foreman::Renderer::PREVIEW_MODE) }

      context 'but without input defined' do
        describe 'rendering' do
          let(:result) { renderer.render(source, real_scope) }
          test "rendering fails and raises an error" do
            e = assert_raises Foreman::Renderer::Errors::UndefinedInput do
              result
            end
            assert_includes e.message, 'service_name'
          end
        end

        describe 'preview' do
          let(:result) { renderer.render(source, preview_scope) }
          test "rendering fails and raises an error" do
            e = assert_raises Foreman::Renderer::Errors::UndefinedInput do
              result
            end
            assert_includes e.message, 'service_name'
          end
        end
      end

      context 'with input defined but not ready' do
        describe 'render' do
          let(:result) { renderer.render(source, real_scope) }
          test "rendering fails and registers an error" do
            template.template_inputs = [FactoryBot.build(:template_input, :name => 'service_name')]
            template.save
            e = assert_raises TemplateInput::ValueNotReady do
              result
            end
            assert_includes e.message, 'service_name'
          end
        end

        describe 'preview' do
          let(:result) { renderer.render(source, preview_scope) }
          test "rendering works using placeholder" do
            template.template_inputs = [FactoryBot.build(:template_input, :name => 'service_name')]
            template.save
            assert_nothing_raised do
              assert_equal "service restart $USER_INPUT[service_name]", result
            end
          end
        end
      end

      context 'with input defined and value provided' do
        let(:real_scope) { Foreman::Renderer::Scope::Provisioning.new(host: @host, source: source, template_input_values: { 'service_name' => 'httpd' }) }
        let(:preview_scope) { Foreman::Renderer::Scope::Provisioning.new(host: @host, source: source, mode: Foreman::Renderer::PREVIEW_MODE, template_input_values: { 'service_name' => 'httpd' }) }

        describe 'render' do
          let(:result) { renderer.render(source, real_scope) }
          test "rendering fails and registers an error" do
            template.template_inputs = [FactoryBot.build(:template_input, :name => 'service_name')]
            template.save
            assert_nothing_raised do
              assert_equal "service restart httpd", result
            end
          end
        end

        describe 'preview' do
          let(:result) { renderer.render(source, preview_scope) }
          test "rendering works using placeholder" do
            template.template_inputs = [FactoryBot.build(:template_input, :name => 'service_name')]
            template.save
            assert_nothing_raised do
              assert_equal "service restart httpd", result
            end
          end
        end
      end
    end

    describe 'input_resource macro' do
      let(:template) { FactoryBot.build(:provisioning_template, template: 'resource: <%= input_resource("ress") -%>') }
      let(:template_inputs) { [FactoryBot.build(:template_input, name: 'ress', value_type: 'resource', resource_type: 'Hostgroup')] }
      let(:source) { Foreman::Renderer::Source::Database.new(template) }

      let(:real_scope) { Foreman::Renderer::Scope::Provisioning.new(**scope_args) }
      let(:preview_scope) { Foreman::Renderer::Scope::Provisioning.new(**scope_args, mode: Foreman::Renderer::PREVIEW_MODE) }

      setup { template.update(template_inputs: template_inputs) }

      context "when resource found" do
        let(:scope_args) { { host: @host, source: source, template_input_values: { 'ress' => hostgroups(:common).id } } }

        test "preview" do
          assert_nothing_raised do
            result = renderer.render(source, preview_scope)
            assert_equal "resource: #{hostgroups(:common).id}", result
          end
        end

        test "render" do
          assert_nothing_raised do
            result = renderer.render(source, real_scope)
            assert_equal "resource: #{hostgroups(:common)}", result
          end
        end
      end

      context "when resource not found" do
        let(:scope_args) { { host: @host, source: source, template_input_values: { 'ress' => 0 } } }

        test "preview" do
          assert_nothing_raised do
            result = renderer.render(source, preview_scope)
            assert_equal 'resource: 0', result
          end
        end

        test "render" do
          assert_raises ActiveRecord::RecordNotFound do
            renderer.render(source, real_scope)
          end
        end
      end

      context "when resource class is not found" do
        let(:template_inputs) { [FactoryBot.build(:template_input, name: 'ress', value_type: 'resource', resource_type: 'NotExistingResource')] }
        let(:scope_args) { { host: @host, source: source, template_input_values: { 'ress' => 0 } } }

        test "preview" do
          assert_nothing_raised do
            result = renderer.render(source, preview_scope)
            assert_equal 'resource: 0', result
          end
        end

        test "render" do
          e = assert_raises Foreman::Renderer::Errors::UnknownResource do
            renderer.render(source, real_scope)
          end
          assert_includes e.message, "Unkown 'NotExistingResource' resource class"
        end
      end

      context "when not authorized" do
        let(:template_inputs) { [FactoryBot.build(:template_input, name: 'ress', value_type: 'resource', resource_type: 'Image')] }
        let(:scope_args) { { host: @host, source: source, template_input_values: { 'ress' => images(:one).id } } }

        test "preview" do
          as_user(users(:one)) do
            assert_nothing_raised do
              result = renderer.render(source, preview_scope)
              assert_equal "resource: #{images(:one).id}", result
            end
          end
        end

        test "render" do
          as_user(users(:one)) do
            assert_raises ActiveRecord::RecordNotFound do
              renderer.render(source, real_scope)
            end
          end
        end
      end

      context "when value is empty" do
        let(:scope_args) { { host: @host, source: source } }

        test "preview" do
          assert_nothing_raised do
            result = renderer.render(source, preview_scope)
            assert_equal "resource: $USER_INPUT[ress]", result
          end
        end

        test "render" do
          e = assert_raises TemplateInput::ValueNotReady do
            renderer.render(source, real_scope)
          end
          assert_includes e.message, "Input 'ress' is not ready for rendering"
        end
      end

      context "when value type != 'resource'" do
        let(:template_inputs) { [FactoryBot.build(:template_input, name: 'ress')] }
        let(:scope_args) { { host: @host, source: source } }

        test "preview" do
          assert_raises Foreman::Renderer::Errors::WrongInputValueType do
            renderer.render(source, real_scope)
          end
        end

        test "render" do
          assert_raises Foreman::Renderer::Errors::WrongInputValueType do
            renderer.render(source, real_scope)
          end
        end
      end
    end
  end
end
