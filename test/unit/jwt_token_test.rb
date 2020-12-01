require 'test_helper'
require 'ostruct'

class JwtTokenTest < ActiveSupport::TestCase
  # Token created from encoding with 'test_jwt_secret' a following payload:
  # { 'user_id' => 123, 'iat' => 1514804400, 'jti' => '3e8286940eb162ec735f8a5aac5926037fdc7f05e521a74231a65f2557a8af94' }
  let(:token) { 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxMjMsImlhdCI6MTUxNDgwNDQwMCwianRpIjoiM2U4Mjg2OTQwZWIxNjJlYzczNWY4YTVhYWM1OTI2MDM3ZmRjN2YwNWU1MjFhNzQyMzFhNjVmMjU1N2E4YWY5NCJ9.TSM2xMnMuMEWwAVoIidyLIwJElJQZVQvcfaxyVA7cDI' }

  test 'encoding' do
    JwtToken.stubs(:iat).returns(1_514_804_400)

    user = OpenStruct.new(id: 123)
    jwt_token = JwtToken.encode(user, 'test_jwt_secret')

    assert_equal token, jwt_token.to_s
  end

  test 'encode with expiration' do
    jwt_secret = FactoryBot.build(:jwt_secret, token: 'test_jwt_secret')
    JwtSecret.stubs(:find_by).returns(jwt_secret)
    user = OpenStruct.new(id: 123)
    jwt_token = JwtToken.new(JwtToken.encode(user, jwt_secret.token, expiration: 3600).token)

    assert_nothing_raised { jwt_token.decode }
  end

  test 'encode with scope (string)' do
    jwt_secret = FactoryBot.build(:jwt_secret, token: 'test_jwt_secret')
    JwtSecret.stubs(:find_by).returns(jwt_secret)
    jwt_token = JwtToken.new(JwtToken.encode(OpenStruct.new(id: 123), jwt_secret.token, scope: 'onescope').token)

    assert_equal 'onescope', jwt_token.decode['scope']
  end

  test 'encode with scope (array)' do
    jwt_secret = FactoryBot.build(:jwt_secret, token: 'test_jwt_secret')
    JwtSecret.stubs(:find_by).returns(jwt_secret)
    scope = ['one', 'two', 'three']
    jwt_token = JwtToken.new(JwtToken.encode(OpenStruct.new(id: 123), jwt_secret.token, scope: scope).token)

    assert_equal 'one two three', jwt_token.decode['scope']
  end

  test 'decoding' do
    jwt_secret = FactoryBot.build(:jwt_secret, token: 'test_jwt_secret')
    JwtSecret.stubs(:find_by).returns(jwt_secret)
    jwt_token = JwtToken.new(token)

    expected = {'user_id' => 123,
                'iat' => 1_514_804_400,
                'jti' => '3e8286940eb162ec735f8a5aac5926037fdc7f05e521a74231a65f2557a8af94'}

    assert_equal expected, jwt_token.decode
  end

  test 'decoding invalid token' do
    jwt_token = JwtToken.new('inVaLiD.inVaLiD.inVaLiD')

    assert_nil jwt_token.decode
  end

  test 'decoding a nil token' do
    jwt_token = JwtToken.new(nil)

    assert_nil jwt_token.decode
  end

  test 'decoding empty token' do
    jwt_token = JwtToken.new('')

    assert_nil jwt_token.decode
  end

  test 'decoding garbage token' do
    jwt_token = JwtToken.new('fjdfhjjkdsjfdjksn')

    assert_nil jwt_token.decode
  end

  test 'decoding with invalid secret' do
    jwt_secret = FactoryBot.build(:jwt_secret, token: 'invalid_jwt_secret')
    JwtSecret.stubs(:find_by).returns(jwt_secret)
    jwt_token = JwtToken.new(token)

    assert_raises JWT::VerificationError do
      jwt_token.decode
    end
  end

  test 'decoding expired token' do
    jwt_secret = FactoryBot.build(:jwt_secret, token: 'test_jwt_secret')
    JwtSecret.stubs(:find_by).returns(jwt_secret)
    user = OpenStruct.new(id: 123)
    jwt_token = JwtToken.new(JwtToken.encode(user, jwt_secret.token, expiration: -1).token)

    assert_raise(JWT::ExpiredSignature) { jwt_token.decode }
  end
end
