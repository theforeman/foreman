require 'test_helper'

class RedhatRegisterTest < ActiveSupport::TestCase
  def render_template(parameters)
    snippet_path = Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'redhat_register.erb')
    snippet = File.read(snippet_path).gsub('<%= snippet', '<%# commented_out_snippet')
    source = OpenStruct.new(name: 'Test', content: snippet)
    host = FactoryBot.create(:host, :managed)

    parameters.each do |name, value|
      FactoryBot.create(:host_parameter, host: host, name: name, value: value)
    end

    scope = Class.new(Foreman::Renderer::Scope::Provisioning).send(
      :new,
      host: host,
      source: source,
      variables: {host: host}
    )

    Foreman::Renderer::SafeModeRenderer.render(source, scope)
  end

  test 'does not install host tools for CDN registration by default' do
    output = render_template('subscription_manager' => 'true')

    assert_no_match(/katello-host-tools/, output)
  end

  test 'installs host tools for Satellite registration by default' do
    output = render_template(
      'subscription_manager' => 'true',
      'subscription_manager_certpkg_url' => 'https://satellite.example.com/pub/katello-ca-consumer.rpm'
    )

    assert_match(/katello-host-tools/, output)
  end

  test 'allows enabling host tools for CDN registration' do
    output = render_template(
      'subscription_manager' => 'true',
      'redhat_install_host_tools' => 'true'
    )

    assert_match(/katello-host-tools/, output)
  end

  test 'allows disabling host tools for Satellite registration' do
    output = render_template(
      'subscription_manager' => 'true',
      'subscription_manager_certpkg_url' => 'https://satellite.example.com/pub/katello-ca-consumer.rpm',
      'redhat_install_host_tools' => 'false'
    )

    assert_no_match(/katello-host-tools/, output)
  end
end
