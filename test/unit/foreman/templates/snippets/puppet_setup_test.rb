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
  WINDOWS_OPENVOX_SOURCE = 'https://downloads.voxpupuli.org/windows/openvox8/openvox-agent-8.29.0-x64.msi'.freeze

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
        assert_no_match(/apt-get install -y puppet-agent/, output)
      end
    end

    test 'uses OpenVox by default' do
      output = render_template(@host)

      assert_includes output, 'apt-get install -y openvox-agent'
      assert_no_match(/puppet-agent|apt-get install -y puppet$/, output)
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
          assert_no_match(/dnf -y install puppet-agent/, output)
        end
      end

      test 'uses OpenVox by default' do
        output = render_template(@host)

        assert_includes output, 'dnf -y install openvox-agent'
        assert_no_match(/puppet-agent|dnf -y install puppet$/, output)
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
          assert_no_match(/dnf -y install puppet-agent/, output)
        end
      end

      test 'uses OpenVox by default' do
        output = render_template(@host)

        assert_includes output, 'dnf -y install openvox-agent'
        assert_no_match(/puppet-agent|dnf -y install puppet$/, output)
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
          assert_no_match(/apt-get install -y puppet-agent/, output)
        end
      end

      test 'uses OpenVox by default' do
        output = render_template(@host)

        assert_includes output, 'apt-get install -y openvox-agent'
        assert_no_match(/puppet-agent|apt-get install -y puppet$/, output)
      end
    end
  end

  context 'FreeBSD' do
    setup do
      @host = FactoryBot.build(:host_for_snapshots, :with_freebsd, build: true)
    end

    test 'uses OpenVox' do
      output = render_template(@host)

      assert_includes output, 'pkg install -y openvox-agent8'
      assert_no_match(/pkg install -y puppet/, output)
    end
  end

  context 'Windows' do
    setup do
      @host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_windows10, build: true)
      @host.host_parameters << FactoryBot.build(
        :host_parameter,
        host: @host,
        name: 'win_puppet_source',
        value: WINDOWS_OPENVOX_SOURCE
      )
    end

    test 'uses the OpenVox installer' do
      output = render_template(@host)

      assert_includes output, "$puppet_agent_source = '#{WINDOWS_OPENVOX_SOURCE}'"
      assert_includes output, '${env:TEMP}\openvox-agent.msi'
      assert_includes output, 'Start-BitsTransfer -Source "${puppet_agent_source}" -Destination "${puppet_agent_msi}"'
      assert_no_match(/puppet-agent-.*\.msi/, output)
    end

    test 'requires the installer source' do
      @host.host_parameters.clear

      error = assert_raises(RuntimeError) do
        render_template(@host)
      end

      assert_equal 'win_puppet_source must be set for OpenVox setup on Windows', error.message
    end
  end

  context 'Suse' do
    setup do
      os = FactoryBot.create(:opensuse_16_0, :with_provision, :with_associations)
      @host = FactoryBot.build(
        :host,
        :managed,
        build: true,
        operatingsystem: os,
        architecture: os.architectures.first
      )
    end

    test 'requires an OpenVox repository' do
      error = assert_raises(RuntimeError) do
        render_template(@host)
      end

      assert_equal 'OpenVox setup on Suse requires an OpenVox repository parameter', error.message
    end

    test 'accepts a configured OpenVox repository' do
      @host.host_parameters << FactoryBot.build(
        :host_parameter,
        host: @host,
        name: 'enable-openvox8-repo',
        value: true
      )

      output = render_template(@host)

      assert_includes output, 'rpmkeys --import https://yum.voxpupuli.org/GPG-KEY-openvox.pub'
    end
  end
end
