require 'test_helper'
require 'foreman/cast'

class CastTest < ActiveSupport::TestCase
  include Foreman::Cast

  test "should convert strings to booleans" do
    true_strings = %w(true t yes y on 1)
    false_strings = %w(false f no n off 0)

    true_strings.each do |true_string|
      assert_equal true, Foreman::Cast.to_bool(true_string)
    end

    false_strings.each do |false_string|
      assert_equal false, Foreman::Cast.to_bool(false_string)
    end
  end

  test "should convert FixNums to booleans" do
    assert_equal true, Foreman::Cast.to_bool(1)
    assert_equal false, Foreman::Cast.to_bool(0)
  end

  test "should convert Nil to boolean" do
    assert_equal false, Foreman::Cast.to_bool(nil)
  end

  test "should return TrueClass if TrueClass" do
    assert_equal true, Foreman::Cast.to_bool(true)
  end

  test "should return FalseClass if FalseClass" do
    assert_equal false, Foreman::Cast.to_bool(false)
  end
end
