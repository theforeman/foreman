require 'test_helper'
require 'ostruct'
require 'openssl'
require 'jwt'

class OidcJwtValidateTest < ActiveSupport::TestCase
  context '#decoded_payload?' do
    def setup
      @jwk ||= JWT::JWK.new(OpenSSL::PKey::RSA.new(2048))
      exp = Time.now.to_i + 4 * 3600
      payload, headers = { "name": "jwt token", "iat": 1557224758, "exp": exp, "typ": "Bearer", "aud": "rest-client", "iss": "127.0.0.1"}, { kid: @jwk.kid }

      Setting['oidc_jwks_url'] = 'https://keycloak.example.com/auth/realms/foreman/protocol/openid-connect/certs'
      Setting['oidc_audience'] = 'rest-client'
      Setting['oidc_issuer'] = '127.0.0.1'
      Setting['oidc_algorithm'] = 'RS512'
      @token = JWT.encode(payload, @jwk.keypair, 'RS512', headers)
      @decoded_payload = payload.with_indifferent_access
    end

    test 'if valid jwk json is passed' do
      stub_request(:get, Setting['oidc_jwks_url'])
        .to_return(body: {"keys": [@jwk.export]}.to_json)
      actual = OidcJwtValidate.new(@token).decoded_payload
      expected = @decoded_payload
      assert_equal expected, actual
    end

    test 'must decode with valid signature and claims' do
      stub_request(:get, Setting['oidc_jwks_url'])
        .to_return(body: {"keys": [@jwk.export]}.to_json)
      actual = OidcJwtValidate.new(@token).decoded_payload
      expected = @decoded_payload
      assert_equal expected, actual
    end

    test 'if signature is not valid' do
      other_jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048))
      stub_request(:get, Setting['oidc_jwks_url'])
        .to_return(body: {"keys": [other_jwk.export]}.to_json)
      actual = OidcJwtValidate.new(@token).decoded_payload
      expected = nil
      assert_nil expected, actual
    end

    test 'if audience is not valid' do
      Setting['oidc_audience'] = "no-client"
      stub_request(:get, Setting['oidc_jwks_url'])
        .to_return(body: {"keys": [@jwk.export]}.to_json)
      actual = OidcJwtValidate.new(@token).decoded_payload
      expected = nil
      assert_nil expected, actual
      Setting['oidc_audience'] = "rest-client"
    end

    test 'if token has expired' do
      stub_request(:get, Setting['oidc_jwks_url'])
        .to_return(body: {"keys": [@jwk.export]}.to_json)
      actual = travel 1.day do
        OidcJwtValidate.new(@token).decoded_payload
      end
      expected = nil
      assert_nil expected, actual
    end

    test 'with invalid token' do
      other_token = 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMjMsImlhdCI6MTUxNDgwNDQwMCwianRpIjoiM2U4Mjg2OTQwZWIxNjJlYzczNWY4YTVhYWM1OTI2MDM3ZmRjN2YwNWU1MjFhNzQyMzFhNjVmMjU1N2E4YWY5NCJ9.TSM2xMnMuMEWwAVoIidyLIwJElJQZVQvcfaxyVA7cDI'
      stub_request(:get, Setting['oidc_jwks_url'])
        .to_return(body: {"keys": [@jwk.export]}.to_json)
      actual = OidcJwtValidate.new(other_token).decoded_payload
      expected = nil
      assert_nil expected, actual
    end
  end
end
