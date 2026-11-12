require 'test_helper'

class Oidc::AccessTokenVerifierTest < ActiveSupport::TestCase
  let(:auth_source) { FactoryBot.build_stubbed(:auth_source_oidc, :oidc_api_audiences => 'foreman-api') }
  let(:jwt_verifier) { mock('JWT verifier') }

  test 'validates required claims with the configured audience' do
    payload = {
      'sub' => 'subject-1',
      'iss' => auth_source.oidc_issuer,
      'aud' => 'foreman-api',
      'exp' => 5.minutes.from_now.to_i,
      'iat' => Time.now.utc.to_i,
    }
    Oidc::JwtVerifier.stubs(:new).with(auth_source).returns(jwt_verifier)
    jwt_verifier.expects(:decode).with('token', :audience => ['foreman-api']).returns(payload)

    assert_equal payload, Oidc::AccessTokenVerifier.new(auth_source).verify('token')
  end

  test 'rejects tokens without a subject' do
    Oidc::JwtVerifier.stubs(:new).returns(jwt_verifier)
    jwt_verifier.stubs(:decode).returns(
      'iss' => auth_source.oidc_issuer,
      'aud' => 'foreman-api',
      'exp' => 5.minutes.from_now.to_i,
      'iat' => Time.now.utc.to_i
    )

    assert_raises(Oidc::AuthenticationError) do
      Oidc::AccessTokenVerifier.new(auth_source).verify('token')
    end
  end
end
