require 'test_helper'

class PasswordHashTest < ActiveSupport::TestCase
  [:bcrypt, :sha1].each do |type|
    test "#{type} generates salt" do
      hasher = Foreman::PasswordHash.new(type)
      refute_empty hasher.generate_salt(1)
    end

    test "#{type} calculates salt" do
      hasher = Foreman::PasswordHash.new(type)
      expected = {
        bcrypt: '$2a$01$a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
        sha1: 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
      }
      assert_equal expected[type], hasher.calculate_salt('test', 1)
    end

    test "#{type} calculates secret hash" do
      hasher = Foreman::PasswordHash.new(type)
      salt = hasher.calculate_salt('test', 6)
      expected = {
        bcrypt: '$2a$06$a94a8fe5ccb19ba61c4c0uwk7Ym1nf2wtDsv067VgkPeQsUuBbfjW',
        sha1: 'da830961dc3af47fff6d1af3be3d66d6f229ef53',
      }
      assert_equal expected[type], hasher.hash_secret('test', salt)
    end
  end
end
