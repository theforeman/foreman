require 'test_helper'

class AuthSourceOidcTest < ActiveSupport::TestCase
  let(:auth_source) { FactoryBot.build(:auth_source_oidc) }

  should validate_presence_of(:name)
  should validate_presence_of(:oidc_issuer)
  should validate_presence_of(:oidc_client_id)
  should have_many(:organizations)
  should have_many(:locations)
  should have_many(:oidc_identities)
  should have_many(:linked_users).through(:oidc_identities)

  test 'accepts a standard confidential client' do
    assert auth_source.valid?, auth_source.errors.full_messages.to_sentence
  end

  test 'requires HTTPS issuer URLs' do
    auth_source.oidc_issuer = 'http://keycloak.example.test/realms/foreman'

    refute auth_source.valid?
    assert auth_source.errors[:oidc_issuer].present?
  end

  test 'rejects issuer identifiers containing credentials, queries, or fragments' do
    [
      'https://user:password@keycloak.example.test/realms/foreman',
      'https://keycloak.example.test/realms/foreman?tenant=one',
      'https://keycloak.example.test/realms/foreman#issuer',
    ].each do |issuer|
      auth_source.oidc_issuer = issuer
      refute auth_source.valid?
      assert auth_source.errors[:oidc_issuer].present?
    end
  end

  test 'requires the openid scope' do
    auth_source.oidc_scopes = 'profile email'

    refute auth_source.valid?
    assert_includes auth_source.errors[:oidc_scopes], 'must include the openid scope'
  end

  test 'allows a public client without a secret' do
    auth_source.oidc_client_auth_method = 'none'

    assert auth_source.valid?, auth_source.errors.full_messages.to_sentence
    assert_nil auth_source.oidc_client_secret
  end

  test 'requires PKCE for public clients' do
    auth_source.oidc_client_auth_method = 'none'
    auth_source.oidc_client_secret = nil
    auth_source.oidc_use_pkce = false

    refute auth_source.valid?
    assert auth_source.errors[:oidc_use_pkce].present?
  end

  test 'rejects unsupported ID token algorithms' do
    ['none', 'HS256', 'unknown'].each do |algorithm|
      auth_source.oidc_allowed_algorithms = algorithm
      refute auth_source.valid?
      assert auth_source.errors[:oidc_allowed_algorithms].present?
    end
  end

  test 'requires an explicit audience for API bearer authentication' do
    auth_source.oidc_allow_api_bearer = true
    auth_source.oidc_api_audiences = nil

    refute auth_source.valid?
    assert auth_source.errors[:oidc_api_audiences].present?
  end

  test 'does not accept browser ID tokens as API bearer tokens' do
    auth_source.oidc_allow_api_bearer = true
    auth_source.oidc_api_audiences = auth_source.oidc_client_id

    refute auth_source.valid?
    assert auth_source.errors[:oidc_api_audiences].present?
  end

  test 'requires endpoints when discovery is disabled' do
    auth_source.oidc_use_discovery = false

    refute auth_source.valid?
    assert auth_source.errors[:oidc_authorization_endpoint].present?
    assert auth_source.errors[:oidc_token_endpoint].present?
    assert auth_source.errors[:oidc_jwks_uri].present?
  end

  test 'stores the client secret encrypted' do
    AuthSourceOidc.any_instance.stubs(:encryption_key).returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    auth_source.save!

    assert auth_source.is_decryptable?(auth_source.oidc_client_secret_in_db)
    refute_equal 'secret', auth_source.oidc_client_secret_in_db
  end

  test 'tests discovery and the provider key set' do
    metadata = { 'jwks_uri' => 'https://idp.example.test/certs' }
    auth_source.expects(:metadata).with(:force => true).returns(metadata)
    verifier = mock('JWT verifier')
    Oidc::JwtVerifier.expects(:new).with(auth_source).returns(verifier)
    verifier.expects(:validate).with(:jwks_uri => metadata['jwks_uri'], :force => true).returns(true)

    assert auth_source.test_connection[:success]
  end

  test 'synchronizes mapped groups and preserves local groups' do
    auth_source.save!
    user = FactoryBot.create(:user)
    local_group = FactoryBot.create(:usergroup)
    old_mapping = FactoryBot.create(:external_usergroup, :name => 'old', :auth_source => auth_source)
    new_mapping = FactoryBot.create(:external_usergroup, :name => 'KEYCLOAK-ADMINS', :auth_source => auth_source)
    user.usergroup_ids = [local_group.id, old_mapping.usergroup_id]

    auth_source.sync_usergroups(user, ['keycloak-admins'])

    assert_includes user.reload.usergroup_ids, local_group.id
    assert_includes user.usergroup_ids, new_mapping.usergroup_id
    refute_includes user.usergroup_ids, old_mapping.usergroup_id
  end
end
