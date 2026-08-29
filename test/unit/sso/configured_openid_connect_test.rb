require 'test_helper'

class ConfiguredOpenidConnectTest < ActiveSupport::TestCase
  let(:auth_source) do
    FactoryBot.create(:auth_source_oidc,
      :oidc_issuer => 'https://idp.example.test',
      :oidc_allow_api_bearer => true,
      :oidc_api_audiences => 'foreman-api')
  end
  let(:user) { FactoryBot.create(:user) }
  let(:payload) do
    {
      'sub' => 'subject-1',
      'iss' => auth_source.oidc_issuer,
      'aud' => 'foreman-api',
      'exp' => 5.minutes.from_now.to_i,
      'iat' => Time.now.utc.to_i,
    }
  end
  let(:token) { JWT.encode(payload, nil, 'none') }
  let(:controller) { api_controller(token) }
  let(:sso) { SSO::ConfiguredOpenidConnect.new(controller) }

  setup do
    FactoryBot.create(:oidc_identity, :auth_source => auth_source, :user => user, :subject => payload['sub'])
  end

  test 'is available for an enabled provider selected by issuer' do
    assert sso.available?
  end

  test 'is not available unless API bearer authentication is enabled' do
    auth_source.update!(:oidc_allow_api_bearer => false)

    refute sso.available?
  end

  test 'rejects ambiguous provider selection' do
    FactoryBot.create(:auth_source_oidc,
      :oidc_issuer => auth_source.oidc_issuer,
      :oidc_api_audiences => 'foreman-api',
      :oidc_allow_api_bearer => true)

    refute sso.available?
  end

  test 'authenticates only an already linked identity' do
    Oidc::AccessTokenVerifier.any_instance.stubs(:verify).returns(payload)

    assert sso.available?
    assert sso.authenticated?
    assert_equal user, sso.current_user
  end

  test 'rejects a disabled linked user' do
    user.update!(:disabled => true)
    Oidc::AccessTokenVerifier.any_instance.stubs(:verify).returns(payload)

    assert sso.available?
    refute sso.authenticated?
  end

  test 'does not provision or link users from API tokens' do
    auth_source.oidc_identities.destroy_all
    Oidc::AccessTokenVerifier.any_instance.stubs(:verify).returns(payload)

    assert sso.available?
    assert_no_difference('User.unscoped.count') do
      refute sso.authenticated?
    end
  end

  private

  def api_controller(bearer_token)
    request = Struct.new(:authorization).new("Bearer #{bearer_token}")
    Struct.new(:request) do
      def api_request?
        true
      end
    end.new(request)
  end
end
