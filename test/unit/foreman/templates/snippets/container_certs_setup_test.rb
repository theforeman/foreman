require 'test_helper'

class ContainerCertsSetupTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_template(registration_host)
    @snippet ||= Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'container_certs_setup.erb').read

    source = OpenStruct.new(
      name: 'Test',
      content: @snippet
    )

    scope = Foreman::Renderer::Scope::Provisioning.new(
      host: nil,
      source: source,
      variables: {
       registration_host: registration_host,
      })

    renderer.render(source, scope)
  end

  test 'should render successfully with valid registration_host' do
    registration_host = 'registry.example.com'
    output = render_template(registration_host)
    assert_includes output, 'hostname="registry.example.com"'
    assert_includes output, "Create directory for certificates\ncert_dir=\"/etc/containers/certs.d/$hostname\""
    assert_includes output, 'ln -sf "$ca_cert" "$cert_dir/ca-bundle.crt"'
    assert_includes output, 'ln -sf "$key_file" "$cert_dir/client.key"'
    assert_includes output, 'ln -sf "$cert_file" "$cert_dir/client.cert"'
    assert_includes output, 'Container certificate setup completed successfully.'
  end

  test 'should raise error when registration_host is blank' do
    assert_raises(RuntimeError, 'Unable to determine registration hostname') do
      render_template(nil)
    end
  end
end
