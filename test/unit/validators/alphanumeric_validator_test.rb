require 'test_helper'

class AlphanumericValidatorTest < ActiveSupport::TestCase
  setup do
    class Validatable
      include ActiveModel::Validations
      validates :name, :alphanumeric => true
      attr_accessor :name
    end
    @item = Validatable.new
  end

  test "validation passes on alphanumeric input" do
    @item.name = "AlphaNumeric123"
    assert @item.valid?
  end

  test "validation fails on whitespace in input" do
    @item.name = "AlphaNumeric 123"
    refute @item.valid?
  end

  test "validation fails on symbol in input" do
    @item.name = "AlphaNumeric@123"
    refute @item.valid?
  end

  test "validation fails on non-english character in input" do
    @item.name = "AlphaNuméric123"
    refute @item.valid?
  end
end
