require 'test_helper'

class BuiltSnippetTest < ActiveSupport::TestCase
  def renderer
    @renderer ||= Foreman::Renderer::SafeModeRenderer
  end

  def render_snippet(host:, variables: {})
    @snippet ||= File.read(Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', 'built.erb'))

    source = OpenStruct.new(
      name: 'built',
      content: @snippet
    )

    scope = Class.new(Foreman::Renderer::Scope::Provisioning).send(
      :new,
      host: host,
      source: source,
      variables: variables)

    renderer.render(source, scope)
  end

  setup do
    disable_orchestration
    os = FactoryBot.create(:operatingsystem, :with_associations)
    @host = FactoryBot.create(:host, :managed, :build => true, :operatingsystem => os)
    @host.build_token(:value => 'test_token', :expires => Time.zone.now + 5.minutes)
    Setting[:unattended_url] = 'http://foreman.example.com'
    # Use actual test certificate for HTTPS tests
    Setting[:ssl_ca_file] = Rails.root.join('test/static_fixtures/certificates/example.com.crt')
  end

  test 'should use HTTP URL by default' do
    result = render_snippet(host: @host)
    assert_match %r{http://foreman.example.com/unattended/built}, result
    assert_match(/test_token/, result)
  end

  test 'should convert to HTTPS when force_https is true' do
    result = render_snippet(host: @host, variables: { force_https: true })
    assert_match %r{https://foreman.example.com/unattended/built}, result
    assert_no_match %r{http://foreman.example.com}, result
  end

  test 'should use curl when available' do
    result = render_snippet(host: @host)
    assert_match(%r{if \[ -x /usr/bin/curl \]}, result)
    assert_match(%r{/usr/bin/curl}, result)
  end

  test 'should use HTTPS URL and set SSL_CA_CERT when force_https is true' do
    result = render_snippet(host: @host, variables: { force_https: true })
    assert_match(/SSL_CA_CERT/, result)
    assert_match(/--cacert \$SSL_CA_CERT/, result)
  end

  test 'should use failed endpoint when specified' do
    result = render_snippet(host: @host, variables: { endpoint: 'failed' })
    assert_match %r{http://foreman.example.com/unattended/failed}, result
  end

  test 'should convert failed endpoint to HTTPS when force_https is true' do
    result = render_snippet(host: @host, variables: { endpoint: 'failed', force_https: true })
    assert_match %r{https://foreman.example.com/unattended/failed}, result
    assert_no_match %r{http://foreman.example.com}, result
  end

  test 'should include post data when specified' do
    post_data = 'Host configuration failed'
    result = render_snippet(host: @host, variables: { post_data: post_data })
    assert_match(/#{post_data}/, result)
  end

  test 'should preserve HTTPS when unattended_url is already HTTPS' do
    Setting[:unattended_url] = 'https://foreman.example.com'
    result = render_snippet(host: @host, variables: { force_https: true })
    assert_match %r{https://foreman.example.com/unattended/built}, result
  end

  test 'should handle custom port with force_https' do
    Setting[:unattended_url] = 'http://foreman.example.com:8080'
    result = render_snippet(host: @host, variables: { force_https: true })
    assert_match %r{https://foreman.example.com:8080/unattended/built}, result
  end

  test 'should remove port 80 when converting to HTTPS' do
    Setting[:unattended_url] = 'http://foreman.example.com:80'
    result = render_snippet(host: @host, variables: { force_https: true })
    assert_match %r{https://foreman.example.com/unattended/built}, result
    assert_no_match(/:80/, result)
  end
end
