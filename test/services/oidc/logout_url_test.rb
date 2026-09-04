require 'test_helper'

class Oidc::LogoutURLTest < ActiveSupport::TestCase
  let(:auth_source) do
    stub(
      'auth source',
      :metadata => {
        'end_session_endpoint' => 'https://idp.example.test/logout?prompt=logout&client_id=old',
      },
      :oidc_client_id => 'foreman'
    )
  end

  test 'builds the provider logout URL' do
    url = Oidc::LogoutURL.new(auth_source, 'https://foreman.example.test/users/login').to_s
    uri = URI.parse(url)
    parameters = URI.decode_www_form(uri.query).to_h

    assert_equal 'https', uri.scheme
    assert_equal 'idp.example.test', uri.host
    assert_equal '/logout', uri.path
    assert_equal 'logout', parameters['prompt']
    assert_equal 'foreman', parameters['client_id']
    assert_equal 'https://foreman.example.test/users/login', parameters['post_logout_redirect_uri']
  end

  test 'returns nil when the provider has no logout endpoint' do
    auth_source.stubs(:metadata).returns({})

    assert_nil Oidc::LogoutURL.new(auth_source, 'https://foreman.example.test/users/login').to_s
  end
end
