require 'test_helper'

class Oidc::IdentityLinkerTest < ActiveSupport::TestCase
  let(:auth_source) { FactoryBot.create(:auth_source_oidc) }
  let(:user) { FactoryBot.create(:user) }
  let(:authentication) do
    Oidc::Authenticator::Result.new(
      :claims => {},
      :subject => 'subject-1',
      :email => 'user@example.test',
      :email_verified => true,
      :groups => []
    )
  end

  test 'links a provider identity without changing the primary authentication source' do
    original_auth_source = user.auth_source

    identity = Oidc::IdentityLinker.new(auth_source, authentication, user).link

    assert_equal user, identity.user
    assert_equal auth_source, identity.auth_source
    assert_equal original_auth_source, user.reload.auth_source
  end

  test 'is idempotent for the same user and provider' do
    first = Oidc::IdentityLinker.new(auth_source, authentication, user).link
    second = Oidc::IdentityLinker.new(auth_source, authentication, user).link

    assert_equal first, second
  end

  test 'does not move an identity between users' do
    Oidc::IdentityLinker.new(auth_source, authentication, user).link

    assert_raises(Oidc::AuthenticationError) do
      Oidc::IdentityLinker.new(auth_source, authentication, FactoryBot.create(:user)).link
    end
  end
end
