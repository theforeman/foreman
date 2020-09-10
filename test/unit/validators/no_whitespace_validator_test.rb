require 'test_helper'

class NoWhitespaceValidatorTest < ActiveSupport::TestCase
  setup do
    class Validatable
      include ActiveModel::Validations
      validates :name, :no_whitespace => true
      attr_accessor :name
    end
    @item = Validatable.new
    @item.name = "nowhitespace"
  end

  test "validation passes when no whitespace is present" do
    assert @item.valid?
  end

  test "validation fails when whitespace is present" do
    @item.name.insert(rand(@item.name.length), ' ')
    refute @item.valid?
  end
end
