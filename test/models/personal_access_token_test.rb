require 'test_helper'

class PersonalAccessTokenTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_presence_of(:user_id)
  should validate_presence_of(:token)
  should belong_to(:user)

  context 'a personal access token' do
    let(:user) { FactoryBot.create(:user) }
    let(:token) { FactoryBot.create(:personal_access_token, :user => user) }
    let(:token_value) do
      token_value = token.generate_token
      token.save
      token_value
    end

    test 'calculates token salt' do
      expected_salt = '$pbkdf2sha1$1000$b1d5781111d84f7b3fe45a0852e59758cd7a87e5'
      user = mock('user')
      user.stubs(:id).returns(10)
      assert_equal expected_salt, PersonalAccessToken.token_salt(user)
    end

    test 'generates token and token hash' do
      PersonalAccessToken.stubs(:token_salt).returns('$pbkdf2sha1$1000$b1d5781111d84f7b3fe45a0852e59758cd7a87e5')
      SecureRandom.stubs(:urlsafe_base64).returns('JHBia2RmMnNoYTEkMTAwMCRiMWQ1NzgxMTExZDg0ZjdiM2ZlNDVhMDg1MmU1OTc1OGNkN2E4N2U1')
      assert_equal 'JHBia2RmMnNoYTEkMTAwMCRiMWQ1NzgxMTExZDg0ZjdiM2ZlNDVhMDg1MmU1OTc1OGNkN2E4N2U1', token.generate_token
      assert_equal '$pbkdf2sha1$1000$b1d5781111d84f7b3fe45a0852e59758cd7a87e5$18ai5/OGgztB9yh1iwjLzQcA/FlSzKHIPM2ZM+CY1MF9UOE4cVB3', token.token
    end

    test 'authenticate_user validates token' do
      assert PersonalAccessToken.authenticate_user(user, token_value)
      assert_not PersonalAccessToken.authenticate_user(user, 'invalid')
    end

    test 'authenticate_user validates legacy token' do
      token_value = token.generate_token(:sha1)
      token.save
      assert PersonalAccessToken.authenticate_user(user, token_value)
      assert_not PersonalAccessToken.authenticate_user(user, 'invalid')
    end

    test 'token revocation' do
      assert_equal false, token.revoked
      assert_equal true, token.active?
      assert_includes PersonalAccessToken.active.where(:user => user), token
      refute_includes PersonalAccessToken.inactive.where(:user => user), token
      token.revoke!
      assert_equal true, token.revoked
      assert_equal false, token.active?
      assert_includes PersonalAccessToken.inactive.where(:user => user), token
      refute_includes PersonalAccessToken.active.where(:user => user), token
    end

    test 'token expiry' do
      assert_equal true, token.expires?
      assert_equal true, token.active?
      assert_includes PersonalAccessToken.active.where(:user => user), token
      refute_includes PersonalAccessToken.inactive.where(:user => user), token
      token.expires_at = Date.yesterday
      token.save
      assert_equal true, token.expires?
      assert_equal false, token.active?
      assert_includes PersonalAccessToken.inactive.where(:user => user), token
      refute_includes PersonalAccessToken.active.where(:user => user), token
    end
  end
end
