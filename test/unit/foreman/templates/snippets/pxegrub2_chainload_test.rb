require 'test_helper'

class PxeGrub2ChainloadTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_template(host)
    @snippet ||= File.read(Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'pxegrub2_chainload.erb'))

    source = OpenStruct.new(
      name: 'Test',
      content: @snippet
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

  setup do
    @host = FactoryBot.create(:host, :managed, :build => true)
  end

  test 'should render connectefi scsi option by default' do
    actual = render_template(@host)

    assert_match(/^ *connectefi scsi/, actual)
  end

  test 'should not render connectefi option if parameter false' do
    FactoryBot.create(:host_parameter, host: @host, name: 'grub2-connectefi', value: 'false')

    actual = render_template(@host)

    assert_no_match(/^ *connectefi/, actual)
  end

  test 'should render connectefi option if parameter present' do
    FactoryBot.create(:host_parameter, host: @host, name: 'grub2-connectefi', value: 'TESTOPT')

    actual = render_template(@host)

    assert_match(/^ *connectefi TESTOPT/, actual)
  end

  test 'should render connectefi option for default template' do
    actual = render_template(nil)

    assert_match(/^ *connectefi scsi/, actual)
  end
end
