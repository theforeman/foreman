require 'test_helper'

class Oidc::TokenVerifierTest < ActiveSupport::TestCase
  let(:key) { JWT::JWK.new(OpenSSL::PKey::RSA.new(2048)) }
  let(:auth_source) do
    FactoryBot.build_stubbed(:auth_source_oidc,
      :oidc_issuer => 'https://idp.example.test',
      :oidc_client_id => 'foreman')
  end
  let(:verifier) { Oidc::TokenVerifier.new(auth_source) }
  let(:nonce) { 'expected-nonce' }

  setup do
    Oidc::JwtVerifier.any_instance.stubs(:jwks).returns(:keys => [key.export])
  end

  test 'verifies the signature and required OpenID Connect claims' do
    payload = valid_payload
    token = JWT.encode(payload, key.keypair, 'RS256', 'kid' => key.kid)

    assert_equal payload, verifier.verify(token, nonce)
  end

  test 'rejects a wrong nonce' do
    token = JWT.encode(valid_payload.merge('nonce' => 'wrong'), key.keypair, 'RS256', 'kid' => key.kid)

    assert_raises(Oidc::AuthenticationError) { verifier.verify(token, nonce) }
  end

  test 'rejects malformed subjects and timestamps' do
    [
      valid_payload.merge('sub' => ['subject-1']),
      valid_payload.merge('iat' => Time.now.utc.to_i.to_s),
    ].each do |payload|
      token = JWT.encode(payload, key.keypair, 'RS256', 'kid' => key.kid)
      assert_raises(Oidc::AuthenticationError) { verifier.verify(token, nonce) }
    end
  end

  test 'rejects a wrong authorized party for multiple audiences' do
    payload = valid_payload.merge('aud' => ['foreman', 'another-client'], 'azp' => 'another-client')
    token = JWT.encode(payload, key.keypair, 'RS256', 'kid' => key.kid)

    assert_raises(Oidc::AuthenticationError) { verifier.verify(token, nonce) }
  end

  test 'rejects algorithms outside the configured allowlist' do
    token = JWT.encode(valid_payload, key.keypair, 'RS512', 'kid' => key.kid)

    assert_raises(Oidc::AuthenticationError) { verifier.verify(token, nonce) }
  end

  test 'verifies an access token hash when present' do
    access_token = 'access-token'
    digest = OpenSSL::Digest::SHA256.digest(access_token)
    at_hash = Base64.urlsafe_encode64(digest.first(digest.bytesize / 2), :padding => false)
    token = JWT.encode(valid_payload.merge('at_hash' => at_hash), key.keypair, 'RS256', 'kid' => key.kid)

    assert_equal at_hash, verifier.verify(token, nonce, access_token)['at_hash']
    assert_raises(Oidc::AuthenticationError) { verifier.verify(token, nonce, 'wrong-token') }
  end

  private

  def valid_payload
    {
      'sub' => 'subject-1',
      'iss' => auth_source.oidc_issuer,
      'aud' => auth_source.oidc_client_id,
      'exp' => 5.minutes.from_now.to_i,
      'iat' => Time.now.utc.to_i,
      'nonce' => nonce,
    }
  end
end
