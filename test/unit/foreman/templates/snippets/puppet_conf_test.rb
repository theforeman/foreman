require 'test_helper'

class PuppetConfSnippetTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_template(host)
    @snippet ||= Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'puppet.conf.erb').read

    source = OpenStruct.new(
      name: 'puppet.conf',
      content: @snippet
    )

    scope = Foreman::Renderer::Scope::Provisioning.new(
      host: host,
      source: source
    )

    renderer.render(source, scope)
  end

  setup do
    disable_orchestration
    operating_system = FactoryBot.create(:operatingsystem, :with_associations)
    @host = FactoryBot.create(:host, :managed, :build => true, :operatingsystem => operating_system)
  end

  test 'renders a custom Puppet server port as masterport' do
    FactoryBot.create(:host_parameter, host: @host, name: 'puppet_server_port', value: '4443')

    result = render_template(@host)

    assert_match(/^masterport\s+= 4443$/, result)
    assert_no_match(/^port\s+= 4443$/, result)
  end

  test 'does not render the default Puppet server port' do
    FactoryBot.create(:host_parameter, host: @host, name: 'puppet_server_port', value: '8140')

    result = render_template(@host)

    assert_no_match(/^masterport\s+=/, result)
  end
end
