require 'test_helper'

class JwtSecretTest < ActiveSupport::TestCase
  test 'generate token before creation' do
    user = FactoryBot.create(:user)
    jwt_secret = user.build_jwt_secret
    jwt_secret.save!
    refute_nil jwt_secret.token
  end
end
