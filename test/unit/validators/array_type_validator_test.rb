require 'test_helper'

class ArrayTypeValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :value, :array_type => true
    attr_accessor :value
  end

  setup do
    @validatable = Validatable.new
  end

  test "should accept array" do
    @validatable.value = ["a", "b", 1]
    assert_valid @validatable
  end

  test "should accept array values" do
    @validatable.value = "a,b,c"
    assert_valid @validatable
  end

  test "should not accept values without comma as separator" do
    @validatable.value = "a b c"
    refute_valid @validatable
  end
end
