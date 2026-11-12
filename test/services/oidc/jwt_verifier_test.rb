require 'test_helper'

class Oidc::JwtVerifierTest < ActiveSupport::TestCase
  let(:auth_source) do
    FactoryBot.build_stubbed(:auth_source_oidc,
      :oidc_issuer => 'https://idp.example.test',
      :oidc_client_id => 'foreman')
  end
  let(:jwks_uri) { 'https://idp.example.test/certs' }
  let(:old_key) { JWT::JWK.new(OpenSSL::PKey::RSA.new(2048)) }
  let(:new_key) { JWT::JWK.new(OpenSSL::PKey::RSA.new(2048)) }

  setup do
    auth_source.stubs(:metadata).returns('jwks_uri' => jwks_uri)
    Rails.cache.delete(Oidc::JwtVerifier.cache_key(auth_source.id))
  end

  teardown do
    Rails.cache.delete(Oidc::JwtVerifier.cache_key(auth_source.id))
  end

  test 'reloads the key set once when the provider rotates keys' do
    cache_keys(old_key)
    stub_request(:get, jwks_uri).to_return(:body => { :keys => [new_key.export] }.to_json)
    token = encode(valid_payload, new_key)

    assert_equal 'subject-1', verifier.decode(token, :audience => 'foreman')['sub']
    assert_requested :get, jwks_uri, :times => 1
  end

  test 'does not reload keys for an expired token' do
    cache_keys(new_key)
    token = encode(valid_payload.merge('exp' => 5.minutes.ago.to_i), new_key)

    assert_raises(JWT::ExpiredSignature) { verifier.decode(token, :audience => 'foreman') }
    assert_not_requested :get, jwks_uri
  end

  private

  def verifier
    @verifier ||= Oidc::JwtVerifier.new(auth_source)
  end

  def cache_keys(key)
    Rails.cache.write(Oidc::JwtVerifier.cache_key(auth_source.id), :keys => [key.export])
  end

  def encode(payload, key)
    JWT.encode(payload, key.keypair, 'RS256', 'kid' => key.kid)
  end

  def valid_payload
    {
      'sub' => 'subject-1',
      'iss' => auth_source.oidc_issuer,
      'aud' => auth_source.oidc_client_id,
      'exp' => 5.minutes.from_now.to_i,
      'iat' => Time.now.utc.to_i,
    }
  end
end
