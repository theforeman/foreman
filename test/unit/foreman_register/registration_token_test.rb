# frozen_string_literal: true

require 'test_helper'

module ForemanRegister
  class RegistrationTokenTest < ActiveSupport::TestCase
    let(:token) do
      'eyJhbGciOiJIUzI1NiJ9.eyJob3N0X2lkIjoxMjMsImlhdCI6MTU1MTcyOTU2MSwianRpIjoiZWI4OTcwNTQ0MWU1NjgzMzg5MDUwOTlkZWQxYzhkNzdkZDYzMGNhNzIzMTBjNDRkMjgzNjIxMjE0YTIxMTJmZCIsImV4cCI6MTU1MTgxNTk2MSwibmJmIjoxNTUxNzI1OTYxfQ.AWGznp2rlZ1H-2QsagNTMpGVjYVqj6Muu_0ZwcmNrZs'
    end

    setup do
      # Travel back in time as above token will eventually expire
      travel_to Time.at(1_551_729_561).utc
    end

    describe 'encoding' do
      it 'encodes a token' do
        RegistrationToken.stubs(:issued_at).returns(1_551_729_561)
        host = OpenStruct.new(id: 123)
        registration_token = RegistrationToken.encode(host, 'some_secret')

        assert_equal token, registration_token.to_s
      end
    end

    describe 'decoding' do
      it 'decodes a token' do
        RegistrationToken.any_instance.stubs(:find_secret).returns('some_secret')

        registration_token = RegistrationToken.new(token)

        expected = {
          'host_id' => 123,
          'iat' => 1_551_729_561,
          'exp' => 1_551_815_961,
          'nbf' => 1_551_725_961,
          'jti' => 'eb89705441e568338905099ded1c8d77dd630ca72310c44d283621214a2112fd',
        }

        assert_equal expected, registration_token.decode
      end

      it 'decodes an empty token' do
        registration_token = RegistrationToken.new('')
        assert_nil registration_token.decode
      end

      it 'decodes a garbage token' do
        registration_token = RegistrationToken.new('fdjsfdsjfd')

        assert_raises JWT::DecodeError do
          registration_token.decode
        end
      end

      it 'decodes with invalid secret' do
        RegistrationToken.any_instance.stubs(:find_secret).returns('invalid_secret')

        registration_token = RegistrationToken.new(token)

        assert_raises JWT::VerificationError do
          registration_token.decode
        end
      end
    end
  end
end
