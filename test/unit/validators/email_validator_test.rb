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

  test 'should pass when email too long' do
    @validatable.mail = ("a" * 250) + "@example.com"
    refute @validatable.valid?
    assert_equal "is too long (maximum is 254 characters)", @validatable.errors.messages[:mail].first
  end

  test 'should allow blank' do
    assert @validatable.valid?
  end

  %w(admin@example.com admin@example--domain.com admin@localhost).each do |mail|
    test "should pass email '#{mail} as valid" do
      @validatable.mail = mail
      assert @validatable.valid?
    end
  end

  %w(
    admin@
    admin@-invalid.com
    admin@invalid-.com
    admin@in_valid.com
  ).each do |mail|
    test "should fail with email '#{mail}'" do
      @validatable.mail = mail
      refute @validatable.valid?
    end
  end
end
