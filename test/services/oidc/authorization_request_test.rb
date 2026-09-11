require 'test_helper'

class Oidc::AuthorizationRequestTest < ActiveSupport::TestCase
  test 'builds an authorization code request with state, nonce, and PKCE' do
    auth_source = FactoryBot.build_stubbed(:auth_source_oidc)
    auth_source.stubs(:metadata).returns('authorization_endpoint' => 'https://idp.example.test/authorize')

    request = Oidc::AuthorizationRequest.new(auth_source, 'https://foreman.example.test/users/oidc/callback')
    query = Rack::Utils.parse_query(URI.parse(request.url).query)

    assert_equal 'code', query['response_type']
    assert_equal auth_source.oidc_client_id, query['client_id']
    assert_equal 'S256', query['code_challenge_method']
    assert query['code_challenge'].present?
    assert_equal query['state'], request.session_data['state']
    assert request.session_data['nonce'].present?
    assert request.session_data['code_verifier'].present?
  end
end
