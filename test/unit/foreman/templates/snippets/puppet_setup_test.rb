require 'test_helper'

class PuppetSetupTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_template(host)
    snippet_path = Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'puppet_setup.erb')
    @snippet ||= File.read(snippet_path)
    # Due to scope, snippet included in a snippet can't be rendered, so they're commented out.
    # Also tests should check if other snippets are included when needed, delegating content checks to respective tests.
    @sanitized_snippet = @snippet.gsub('<%= snippet', '<%# commented_out_snippet')

    source = OpenStruct.new(
      name: 'Test',
      content: @sanitized_snippet
    )

    scope = Class.new(Foreman::Renderer::Scope::Provisioning).send(
      :new,
      host: host,
      source: source,
      variables: {
        host: host,
      })

    renderer.render(source, scope)
  end

  ENABLE_OPENVOX_PARAMS = [
    'enable-openvox9',
    'enable-openvox9-repo',
    'enable-openvox8',
    'enable-openvox8-repo',
  ].freeze

  # ---------------------------------- DEBIAN ---------------------------------- #
  context 'Debian 13' do
    setup do
      os = FactoryBot.create(:debian13_0, :with_provision, :with_associations)
      @host = FactoryBot.create(:host, :managed, build: true, operatingsystem: os)
    end

    ENABLE_OPENVOX_PARAMS.each do |param_enables_openvox|
      test "#{param_enables_openvox} enables OpenVox" do
        FactoryBot.create(:host_parameter, host: @host, name: param_enables_openvox, value: 'true')
        output = render_template(@host)

        assert_includes output, 'apt-get install -y openvox-agent'
        assert_no_match('apt-get install -y puppet-agent', output)
      end
    end

    test 'Puppet and OpenVox are mutually exclusive - #1' do
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9', value: true)
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-puppetlabs-repo', value: true)

      assert_raises(RuntimeError) do
        render_template(@host)
      end
    end

    test 'Puppet and OpenVox are mutually exclusive - #2' do
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)
      FactoryBot.create(:host_parameter, host: @host, name: 'enable-puppetlabs-repo', value: true)

      assert_raises(RuntimeError) do
        render_template(@host)
      end
    end
  end

  # ------------------------------------ EL9 ----------------------------------- #
  [:rhel9, :for_snapshots_rocky9].each do |el9_factory|
    context el9_factory.to_s do
      setup do
        os = FactoryBot.create(el9_factory, :with_provision, :with_associations)
        @host = FactoryBot.create(:host, :managed, build: true, operatingsystem: os)
      end

      ENABLE_OPENVOX_PARAMS.each do |param_enables_openvox|
        test "#{param_enables_openvox} enables OpenVox" do
          FactoryBot.create(:host_parameter, host: @host, name: param_enables_openvox, value: 'true')
          output = render_template(@host)

          assert_includes output, 'dnf -y install openvox-agent'
          assert_no_match('dnf -y install puppet-agent', output)
        end
      end

      test 'Puppet and OpenVox are mutually exclusive - #1' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9', value: true)
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-puppetlabs-repo', value: true)

        assert_raises(RuntimeError) do
          render_template(@host)
        end
      end

      test 'Puppet and OpenVox are mutually exclusive - #2' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-puppetlabs-repo', value: true)

        assert_raises(RuntimeError) do
          render_template(@host)
        end
      end
    end
  end

  # ----------------------------------- EL10 ----------------------------------- #
  [:rhel10, :for_snapshots_rocky10].each do |el10_factory|
    context el10_factory.to_s do
      setup do
        os = FactoryBot.create(el10_factory, :with_provision, :with_associations)
        @host = FactoryBot.create(:host, :managed, build: true, operatingsystem: os)
      end

      ENABLE_OPENVOX_PARAMS.each do |param_enables_openvox|
        test "#{param_enables_openvox} enables OpenVox" do
          FactoryBot.create(:host_parameter, host: @host, name: param_enables_openvox, value: 'true')
          output = render_template(@host)

          assert_includes output, 'dnf -y install openvox-agent'
          assert_no_match('dnf -y install puppet-agent', output)
        end
      end

      test 'Puppet and OpenVox are mutually exclusive - #1' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9', value: true)
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-puppetlabs-repo', value: true)

        assert_raises(RuntimeError) do
          render_template(@host)
        end
      end

      test 'Puppet and OpenVox are mutually exclusive - #2' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-puppetlabs-repo', value: true)

        assert_raises(RuntimeError) do
          render_template(@host)
        end
      end
    end
  end

  # ---------------------------------- UBUNTU ---------------------------------- #
  [:ubuntu22_04, :ubuntu22_04_3].each do |ubuntu_22_factory|
    context ubuntu_22_factory.to_s do
      setup do
        os = FactoryBot.create(ubuntu_22_factory, :with_provision, :with_associations)
        @host = FactoryBot.create(:host, :managed, build: true, operatingsystem: os)
      end

      ENABLE_OPENVOX_PARAMS.each do |param_enables_openvox|
        test "#{param_enables_openvox} enables OpenVox" do
          FactoryBot.create(:host_parameter, host: @host, name: param_enables_openvox, value: 'true')
          output = render_template(@host)

          assert_includes output, 'apt-get install -y openvox-agent'
          assert_no_match('apt-get install -y puppet-agent', output)
        end
      end

      test 'Puppet and OpenVox are mutually exclusive - #1' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9', value: true)
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-puppetlabs-repo', value: true)

        assert_raises(RuntimeError) do
          render_template(@host)
        end
      end

      test 'Puppet and OpenVox are mutually exclusive - #2' do
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-openvox9-repo', value: true)
        FactoryBot.create(:host_parameter, host: @host, name: 'enable-puppetlabs-repo', value: true)

        assert_raises(RuntimeError) do
          render_template(@host)
        end
      end
    end
  end
end
