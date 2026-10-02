require 'test_helper'

class Oidc::UserResolverTest < ActiveSupport::TestCase
  let(:auth_source) { FactoryBot.create(:auth_source_oidc, :onthefly_register => true) }
  let(:authentication) do
    Oidc::Authenticator::Result.new(
      :claims => {
        'preferred_username' => 'keycloak-user',
        'given_name' => 'Keycloak',
        'family_name' => 'User',
        'email' => 'keycloak@example.test',
      },
      :subject => 'subject-1',
      :email => 'keycloak@example.test',
      :email_verified => true,
      :groups => []
    )
  end

  test 'provisions a user and a separate provider identity' do
    result = Oidc::UserResolver.new(auth_source, authentication).resolve

    assert result.created
    assert_equal 'keycloak-user', result.user.login
    assert_equal auth_source, result.user.auth_source
    assert_equal 'subject-1', result.identity.subject
  end

  test 'resolves a returning identity without creating another user' do
    first = Oidc::UserResolver.new(auth_source, authentication).resolve
    User.current = nil

    assert_no_difference('User.unscoped.count') do
      second = Oidc::UserResolver.new(auth_source, authentication).resolve
      assert_equal first.user, second.user
      refute second.created
    end
  end

  test 'links an existing account only with verified email when enabled' do
    existing = FactoryBot.create(:user, :mail => authentication.email)
    auth_source.update!(:oidc_link_verified_email => true, :onthefly_register => false)

    result = Oidc::UserResolver.new(auth_source, authentication).resolve

    assert_equal existing, result.user
    assert_equal existing.auth_source, result.user.auth_source
  end

  test 'does not link an existing account with an unverified email' do
    FactoryBot.create(:user, :mail => authentication.email)
    auth_source.update!(:oidc_link_verified_email => true, :onthefly_register => false)
    authentication.email_verified = false

    assert_raises(Oidc::AuthenticationError) do
      Oidc::UserResolver.new(auth_source, authentication).resolve
    end
  end

  test 'rejects ambiguous verified email links' do
    2.times { FactoryBot.create(:user, :mail => authentication.email) }
    auth_source.update!(:oidc_link_verified_email => true, :onthefly_register => false)

    assert_raises(Oidc::AuthenticationError) do
      Oidc::UserResolver.new(auth_source, authentication).resolve
    end
  end

  test 'never links hidden system users by email' do
    hidden_user = users(:anonymous)
    hidden_user.update_column(:mail, authentication.email)
    auth_source.update!(:oidc_link_verified_email => true, :onthefly_register => false)

    assert_raises(Oidc::AuthenticationError) do
      Oidc::UserResolver.new(auth_source, authentication).resolve
    end
  end

  test 'rejects a disabled linked account' do
    user = FactoryBot.create(:user, :disabled => true)
    FactoryBot.create(:oidc_identity, :auth_source => auth_source, :user => user,
      :subject => authentication.subject)

    assert_raises(Oidc::AuthenticationError) do
      Oidc::UserResolver.new(auth_source, authentication).resolve
    end
  end

  test 'avoids login collisions without linking by login' do
    FactoryBot.create(:user, :login => 'keycloak-user')

    result = Oidc::UserResolver.new(auth_source, authentication).resolve

    assert_match(/\Akeycloak-user-[0-9a-f]{8}\z/, result.user.login)
  end
end
