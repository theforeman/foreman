require 'test_helper'

class PuppetlabsRepoTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_template(parameters)
    @snippet ||= File.read(Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'puppetlabs_repo.erb'))
    @host.stubs(:params).returns(parameters)
    @host.stubs(:host_param).returns(nil)

    source = OpenStruct.new(
      name: 'Test',
      content: @snippet
    )
    scope = Class.new(Foreman::Renderer::Scope::Provisioning).send(
      :new,
      host: @host,
      source: source
    )

    renderer.render(source, scope)
  end

  setup do
    @host = FactoryBot.build(
      :host_for_snapshots_ipv4_dhcp_windows10,
      architecture: FactoryBot.build(:architecture, :x64)
    )
  end

  test 'uses the generic Puppet collection on Windows' do
    rendered = render_template('enable-puppetlabs-repo' => true)

    assert_includes rendered, 'https://downloads.puppet.com/windows/puppet/puppet-agent-x64-latest.msi'
  end

  test 'uses the Puppet 8 collection on Windows' do
    rendered = render_template('enable-official-puppet8-repo' => true)

    assert_includes rendered, 'https://downloads.puppet.com/windows/puppet8/puppet-agent-x64-latest.msi'
  end

  test 'normalizes 64-bit architecture names for Puppet downloads on Windows' do
    %w[x86_64 x86-64 amd64].each do |architecture|
      @host.architecture = FactoryBot.build(:architecture, name: architecture)

      rendered = render_template('enable-official-puppet8-repo' => true)

      assert_includes rendered, 'https://downloads.puppet.com/windows/puppet8/puppet-agent-x64-latest.msi'
    end
  end

  test 'normalizes 32-bit architecture names for Puppet downloads on Windows' do
    %w[x86 i386 i486 i586 i686].each do |architecture|
      @host.architecture = FactoryBot.build(:architecture, name: architecture)

      rendered = render_template('enable-official-puppet8-repo' => true)

      assert_includes rendered, 'https://downloads.puppet.com/windows/puppet8/puppet-agent-x86-latest.msi'
    end
  end
end
