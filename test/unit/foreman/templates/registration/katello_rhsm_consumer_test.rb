require 'test_helper'

class KatelloRhsmConsumerTemplateTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_template(template_url: 'https://foreman.example.com')
    template = Rails.root.join(
      'app', 'views', 'unattended', 'provisioning_templates', 'registration', 'katello_rhsm_consumer.erb'
    ).read

    source = Foreman::Renderer::Source::Database.new(
      OpenStruct.new(
        name: 'katello-rhsm-consumer',
        template: template
      )
    )

    scope = Foreman::Renderer::Scope::Provisioning.new(
      host: nil,
      source: source,
      params: {
        'url' => template_url,
        :static => '',
      })

    renderer.render(source, scope)
  end

  setup do
    %w[subscription_manager_setup pkg_manager ca_registration].each do |snippet_name|
      FactoryBot.create(
        :provisioning_template,
        :snippet,
        name: snippet_name,
        template: Rails.root.join(
          'app', 'views', 'unattended', 'provisioning_templates', 'snippet', "#{snippet_name}.erb"
        ).read
      )
    end

    Foreman::Renderer::Scope::Provisioning.any_instance
      .stubs(:plugin_present?)
      .with('katello')
      .returns(true)

    Foreman::Renderer::Scope::Provisioning.any_instance
      .stubs(:foreman_server_ca_cert)
      .returns("SERVER CA CERT\nDEFAULT CA CERT\n")
  end

  test 'renders subscription-manager configuration for the satellite hostname' do
    output = render_template

    assert_includes output, 'subscription-manager config \\'
    assert_includes output, '--server.hostname="foreman.example.com" \\'
    assert_includes output, '--server.prefix="/rhsm" \\'
    assert_includes output, '--server.port="443" \\'
    assert_includes output, '--rhsm.repo_ca_cert="$KATELLO_SERVER_CA_CERT" \\'
    assert_includes output, '--rhsm.baseurl="https://foreman.example.com/pulp/content/" \\'
    assert_includes output, '--rhsm.manage_repos=1'
  end

  test 'renders katello CA certificate using the ca_registration snippet' do
    output = render_template

    assert_includes output, 'KATELLO_SERVER_CA_CERT=/etc/rhsm/ca/katello-server-ca.pem'
    assert_includes output, 'touch $KATELLO_SERVER_CA_CERT'
    assert_includes output, 'chmod 644 $KATELLO_SERVER_CA_CERT'
    assert_includes output, 'cat << EOF-', 'expected CA certificates to be written with heredocs'
    assert_includes output, '> "$KATELLO_SERVER_CA_CERT"'
    assert_includes output, 'SERVER CA CERT'
    assert_includes output, 'DEFAULT CA CERT'
    assert_not_includes output, 'KATELLO_DEFAULT_CA_CERT'
  end

  test 'preserves a non-default HTTPS port in RHSM configuration and content base URL' do
    output = render_template(template_url: 'https://foreman.example.com:8443')

    assert_includes output, '--server.hostname="foreman.example.com" \\'
    assert_includes output, '--server.port="8443" \\'
    assert_includes output, '--rhsm.baseurl="https://foreman.example.com:8443/pulp/content/" \\'
  end
end
