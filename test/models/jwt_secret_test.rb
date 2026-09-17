require 'test_helper'

class JwtSecretTest < ActiveSupport::TestCase
  subject { JwtSecret.new(user: FactoryBot.create(:user)) }

  should validate_uniqueness_of(:user)

  test 'generate token before creation' do
    user = FactoryBot.create(:user)
    jwt_secret = user.build_jwt_secret
    jwt_secret.save!
    refute_nil jwt_secret.token
  end

  context 'jwt_secret! create race' do
    let(:user) { FactoryBot.create(:user) }
    let(:existing) { JwtSecret.create!(user_id: user.id) }

    test 'reloads after RecordNotUnique from a concurrent create' do
      user.stubs(:jwt_secret).returns(nil)
      user.stubs(:create_jwt_secret!).raises(ActiveRecord::RecordNotUnique, 'duplicate key')
      user.stubs(:reload_jwt_secret).returns(existing)

      assert_equal existing, user.jwt_secret!
    end

    test 'reloads after RecordInvalid from the uniqueness validation' do
      invalid = JwtSecret.new(user_id: user.id)
      invalid.errors.add(:user, :taken)

      user.stubs(:jwt_secret).returns(nil)
      user.stubs(:create_jwt_secret!).raises(ActiveRecord::RecordInvalid.new(invalid))
      user.stubs(:reload_jwt_secret).returns(existing)

      assert_equal existing, user.jwt_secret!
    end

    test 're-raises when the reload also finds nothing' do
      user.stubs(:jwt_secret).returns(nil)
      user.stubs(:create_jwt_secret!).raises(ActiveRecord::RecordNotUnique, 'duplicate key')
      user.stubs(:reload_jwt_secret).returns(nil)

      assert_raises(ActiveRecord::RecordNotUnique) { user.jwt_secret! }
    end
  end
end
