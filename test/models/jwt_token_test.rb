require 'test_helper'
require 'ostruct'

class JwtTokenTest < ActiveSupport::TestCase
  test 'encoding' do
    Time.zone = 'Europe/Berlin'
    time = Time.local(2018, 1, 1, 12, 0, 0)
    Time.stubs(:now).returns(time)

    user = OpenStruct.new(id: 123)
    jwt_token = JwtToken.encode(user, 'test_jwt_secret')

    assert_equal token, jwt_token.to_s
  end

  test 'decoding' do
    jwt_secret = FactoryBot.build(:jwt_secret, token: 'test_jwt_secret')
    JwtSecret.stubs(:for_user).returns(jwt_secret)
    jwt_token = JwtToken.new(token)

    expected = {'user_id' => 123,
                'iat' => 1_514_804_400,
                'jti' => 'b4e196b3dd77f9e2116ba086a1a9b435'}

    assert_equal expected, jwt_token.decode
  end

  test 'decoding invalid token' do
    jwt_token = JwtToken.new('inVaLiD.inVaLiD.inVaLiD')

    assert_nil jwt_token.decode
  end

  test 'decoding empty token' do
    jwt_token = JwtToken.new('')

    assert_nil jwt_token.decode
  end

  test 'decoding with invalid secret' do
    jwt_secret = FactoryBot.build(:jwt_secret, token: 'invalid_jwt_secret')
    JwtSecret.stubs(:for_user).returns(jwt_secret)
    jwt_token = JwtToken.new(token)

    assert_raises JWT::VerificationError do
      jwt_token.decode
    end
  end

  # Token created from encoding with 'test_jwt_secret' a following payload:
  #
  # { 'user_id' => 123, 'iat' => 1514804400, 'jti' => 'b4e196b3dd77f9e2116ba086a1a9b435' }
  def token
    'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMjMsImlhdCI6MTUxNDgwNDQwMCwianRpIjoiYjRlMTk2YjNkZDc3ZjllMjExNmJhMDg2YTFhOWI0MzUifQ.GkZWjmsRP1v9KrcJGBaH2PJlSoPKALWtYMkJy6OaZhA'
  end
end
