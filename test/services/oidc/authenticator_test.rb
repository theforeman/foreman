require 'test_helper'

class Oidc::AuthenticatorTest < ActiveSupport::TestCase
  let(:auth_source) { FactoryBot.build_stubbed(:auth_source_oidc, :oidc_client_id => 'foreman', :oidc_client_secret => 'secret') }
  let(:http_client) { mock('HTTP client') }
  let(:token_verifier) { mock('token verifier') }
  let(:metadata) do
    {
      'token_endpoint' => 'https://idp.example.test/token',
      'userinfo_endpoint' => 'https://idp.example.test/userinfo',
    }
  end

  setup do
    auth_source.stubs(:metadata).returns(metadata)
    Oidc::HttpClient.stubs(:new).with(auth_source).returns(http_client)
    Oidc::TokenVerifier.stubs(:new).with(auth_source).returns(token_verifier)
  end

  test 'exchanges the authorization code and combines matching UserInfo claims' do
    http_client.expects(:post_form).with(
      metadata['token_endpoint'],
      includes(:grant_type => 'authorization_code', :code => 'code', :code_verifier => 'verifier'),
      includes(:authorization)
    ).returns('id_token' => 'id-token', 'access_token' => 'access-token', 'token_type' => 'Bearer')
    token_verifier.expects(:verify).with('id-token', 'nonce', 'access-token').returns(
      'sub' => 'subject-1', 'preferred_username' => 'user'
    )
    http_client.expects(:get_json)
      .with(metadata['userinfo_endpoint'], :authorization => 'Bearer access-token')
      .returns('sub' => 'subject-1', 'email' => 'user@example.test', 'email_verified' => true, 'groups' => ['admins'])

    result = Oidc::Authenticator.new(auth_source, 'https://foreman.example.test/users/oidc/callback')
      .authenticate('code', 'nonce', 'verifier')

    assert_equal 'subject-1', result.subject
    assert_equal 'user@example.test', result.email
    assert result.email_verified
    assert_equal ['admins'], result.groups
  end

  test 'sends public client identification in the request body' do
    auth_source.oidc_client_auth_method = 'none'
    http_client.expects(:post_form).with(
      metadata['token_endpoint'],
      includes(:client_id => auth_source.oidc_client_id),
      { :content_type => 'application/x-www-form-urlencoded' }
    ).returns('id_token' => 'id-token')
    token_verifier.stubs(:verify).returns('sub' => 'subject-1')

    Oidc::Authenticator.new(auth_source, 'https://foreman.example.test/users/oidc/callback')
      .authenticate('code', 'nonce')
  end

  test 'rejects UserInfo for a different subject' do
    http_client.stubs(:post_form).returns('id_token' => 'id-token', 'access_token' => 'access-token', 'token_type' => 'Bearer')
    token_verifier.stubs(:verify).returns('sub' => 'subject-1')
    http_client.stubs(:get_json).returns('sub' => 'subject-2')

    assert_raises(Oidc::AuthenticationError) do
      Oidc::Authenticator.new(auth_source, 'https://foreman.example.test/users/oidc/callback')
        .authenticate('code', 'nonce')
    end
  end

  test 'rejects a non-bearer access token' do
    http_client.stubs(:post_form).returns('id_token' => 'id-token', 'access_token' => 'access-token', 'token_type' => 'MAC')

    assert_raises(Oidc::AuthenticationError) do
      Oidc::Authenticator.new(auth_source, 'https://foreman.example.test/users/oidc/callback')
      .authenticate('code', 'nonce')
    end
  end

  test 'ignores non-string and oversized group claims' do
    http_client.stubs(:post_form).returns('id_token' => 'id-token', 'access_token' => 'access-token', 'token_type' => 'Bearer')
    token_verifier.stubs(:verify).returns('sub' => 'subject-1')
    http_client.stubs(:get_json).returns(
      'sub' => 'subject-1', 'groups' => ['admins', { 'name' => 'invalid' }, 'x' * 256]
    )

    result = Oidc::Authenticator.new(auth_source, 'https://foreman.example.test/users/oidc/callback')
      .authenticate('code', 'nonce')

    assert_equal ['admins'], result.groups
  end
end
