require 'test_helper'

class ValidatorTest < ActiveSupport::TestCase
  class ValidatedItem
    include ActiveModel::Validations
    attr_accessor :value
  end
  before do
    @item = ValidatedItem.new
  end

  it "adds errors on wrong regexp" do
    @item.value = "123"
    validator = Foreman::Parameters::Validator.new(@item, :type => :regexp, :validate_with => "[a-z]", :getter => :value)
    refute validator.validate!
    assert @item.errors.present?
    assert_equal @item.errors[:value], ["is invalid"]
  end

  it "validates regexp" do
    @item.value = "abdfgfdger"
    validator = Foreman::Parameters::Validator.new(@item, :type => :regexp, :validate_with => "[a-z]", :getter => :value)
    assert validator.validate!
    assert @item.errors.blank?
  end

  it "adds errors on wrong item" do
    validator_rule = "a,b,c"
    @item.value = "d"
    validator = Foreman::Parameters::Validator.new(@item, :type => :list, :validate_with => validator_rule, :getter => :value)
    refute validator.validate!
    assert @item.errors.present?
    assert_equal @item.errors[:value], ["d is not one of a,b,c"]
  end

  it "validates inclusion in list" do
    validator_rule = "a,b,c"
    @item.value = "a"
    validator = Foreman::Parameters::Validator.new(@item, :type => :list, :validate_with => validator_rule, :getter => :value)
    assert validator.validate!
    assert @item.errors.blank?
  end

  it "validates list of integers" do
    validator_rule = "1,2"
    @item.value = 1
    validator = Foreman::Parameters::Validator.new(@item, :type => :list, :validate_with => validator_rule, :getter => :value)
    assert validator.validate!
    refute @item.errors.present?
  end
end
