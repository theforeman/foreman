require 'test_helper'

class EmailValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :mail, :email => true, :allow_blank => true
    attr_accessor :mail
  end

  def setup
    @validatable = Validatable.new
  end

  test 'should pass when email is valid' do
    @validatable.mail = 'admin@example.com'
    assert @validatable.valid?
  end

  test 'should fail when email invalid' do
    @validatable.mail = 'invalid@'
    refute @validatable.valid?
  end

  test 'should pass when email too long' do
    @validatable.mail = ("a" * 250) + "@example.com"
    refute @validatable.valid?
    assert_equal "is too long (maximum is 254 characters)", @validatable.errors.messages[:mail].first
  end

  test 'should allow blank' do
    assert @validatable.valid?
  end

  test "email address can be UTF-8 encoded" do
    @validatable.mail = "Pelé@example.com"
    assert @validatable.valid?
  end
end
