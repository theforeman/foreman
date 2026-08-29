require 'test_helper'

class Oidc::ProviderMetadataTest < ActiveSupport::TestCase
  let(:auth_source) { FactoryBot.build_stubbed(:auth_source_oidc, :oidc_issuer => 'https://idp.example.test/realms/foreman') }
  let(:client) { mock('http client') }
  let(:metadata) do
    {
      'issuer' => auth_source.oidc_issuer,
      'authorization_endpoint' => 'https://idp.example.test/authorize',
      'token_endpoint' => 'https://idp.example.test/token',
      'jwks_uri' => 'https://idp.example.test/certs',
      'userinfo_endpoint' => 'https://idp.example.test/userinfo',
      'code_challenge_methods_supported' => ['S256'],
      'response_types_supported' => ['code'],
      'id_token_signing_alg_values_supported' => ['RS256'],
    }
  end

  setup do
    Oidc::HttpClient.stubs(:new).with(auth_source).returns(client)
    client.stubs(:validate_url!).with(anything).returns(true)
  end

  test 'loads and validates discovery metadata' do
    client.expects(:get_json)
      .with('https://idp.example.test/realms/foreman/.well-known/openid-configuration')
      .returns(metadata)

    result = Oidc::ProviderMetadata.new(auth_source).fetch(:force => true)

    assert_equal metadata['authorization_endpoint'], result['authorization_endpoint']
  end

  test 'rejects a mismatched discovered issuer' do
    client.stubs(:get_json).returns(metadata.merge('issuer' => 'https://attacker.example.test'))

    assert_raises(Oidc::ConfigurationError) do
      Oidc::ProviderMetadata.new(auth_source).fetch(:force => true)
    end
  end

  test 'rejects providers without PKCE S256 support' do
    client.stubs(:get_json).returns(metadata.merge('code_challenge_methods_supported' => ['plain']))

    assert_raises(Oidc::ConfigurationError) do
      Oidc::ProviderMetadata.new(auth_source).fetch(:force => true)
    end
  end

  test 'validates optional endpoints before using them' do
    client.expects(:get_json).returns(metadata.merge('end_session_endpoint' => 'https://idp.example.test/logout'))
    client.expects(:validate_url!).with('https://idp.example.test/logout')

    Oidc::ProviderMetadata.new(auth_source).fetch(:force => true)
  end

  test 'rejects providers without a configured signing algorithm' do
    client.stubs(:get_json).returns(metadata.merge('id_token_signing_alg_values_supported' => ['ES256']))

    assert_raises(Oidc::ConfigurationError) do
      Oidc::ProviderMetadata.new(auth_source).fetch(:force => true)
    end
  end
end
