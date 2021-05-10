require 'test_helper'

class PasswordHashTest < ActiveSupport::TestCase
  [:pbkdf2sha1, :bcrypt, :sha1].each do |type|
    test "#{type} generates salt" do
      hasher = Foreman::PasswordHash.new(type)
      refute_empty hasher.generate_salt(1)
    end

    test "#{type} calculates salt" do
      hasher = Foreman::PasswordHash.new(type)
      expected = {
        sha1: 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
        bcrypt: '$2a$01$a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
        pbkdf2sha1: '$pbkdf2sha1$1$a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
      }
      assert_equal expected[type], hasher.calculate_salt('test', 1)
    end

    test "#{type} calculates secret hash" do
      hasher = Foreman::PasswordHash.new(type)
      cost = {
        sha1: 0,
        bcrypt: 6,
        pbkdf2sha1: 1000,
      }
      salt = hasher.calculate_salt('test', cost[type])
      expected = {
        sha1: 'da830961dc3af47fff6d1af3be3d66d6f229ef53',
        bcrypt: '$2a$06$a94a8fe5ccb19ba61c4c0uwk7Ym1nf2wtDsv067VgkPeQsUuBbfjW',
        pbkdf2sha1: '$pbkdf2sha1$1000$a94a8fe5ccb19ba61c4c0873d391e987982fbbd3$CvVg5fn5f5b15dfMCAoUr4XKmeXmpWa3rz4Yf8a22VzVm+Ni7Ah2',
      }
      assert_equal expected[type], hasher.hash_secret('test', salt)
    end

    test "#{type} is detected from salt" do
      salts = {
        sha1: 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
        bcrypt: '$2a$01$a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
        pbkdf2sha1: '$pbkdf2sha1$1$a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',
      }
      assert_equal type, Foreman::PasswordHash.detect_implementation(salts[type])
    end
  end

  test "different bcrypt costs generate different results" do
    hasher = Foreman::PasswordHash.new(:bcrypt)
    h1 = '$2a$04$a94a8fe5ccb19ba61c4c0uZUfqcn0ZV1N1n2vaPu3jltBG.l7rwCO'
    h2 = '$2a$05$a94a8fe5ccb19ba61c4c0uGMSJMjyrccWFxVlbS7jwCiFRmiZ2f2.'
    assert_equal h1, hasher.hash_secret('test', hasher.calculate_salt('test', 4))
    assert_equal h2, hasher.hash_secret('test', hasher.calculate_salt('test', 5))
  end

  test "different pbkdf2sha1 costs generate different results" do
    hasher = Foreman::PasswordHash.new(:pbkdf2sha1)
    h1 = '$pbkdf2sha1$100$a94a8fe5ccb19ba61c4c0873d391e987982fbbd3$jndR81G+UMxHOfxW9sDqhrvNodEBPoLMFhP3dsoOoHJJm+ncfX5d'
    h2 = '$pbkdf2sha1$200$a94a8fe5ccb19ba61c4c0873d391e987982fbbd3$mUK8prtJkKFlm7KruqIxOIXZTt+niYl0H8zhjmEMqr0sWlEWfxDo'
    assert_equal h1, hasher.hash_secret('test', hasher.calculate_salt('test', 100))
    assert_equal h2, hasher.hash_secret('test', hasher.calculate_salt('test', 200))
  end
end
