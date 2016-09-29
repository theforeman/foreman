require 'test_helper'

class RegexpValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :ip, :regexp => true
    attr_accessor :ip
  end

  setup do
    @validatable = Validatable.new
  end

  test "shlould accept empty value" do
    @validatable.ip = ""
    assert_valid @validatable
  end

  test "should accept valid ip" do
    @validatable.ip = "127.0.0.1"
    assert_valid @validatable
  end

  test "should accept valid ips" do
    @validatable.ip = "127.0.0.1|192.168.100.122"
    assert_valid @validatable
  end

  test "should allow digit matching" do
    @validatable.ip = '^19\d.\d+.13.\d8|127.0.0.1$'
    assert_valid @validatable
  end

  test "should not accept invalid regexp" do
    @validatable.ip = "\\"
    refute_valid @validatable
  end
end
