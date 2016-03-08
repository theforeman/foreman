require 'test_helper'

class IpRegexpValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :ip, :ip_regexp => true
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

  test "should not accept random string" do
    @validatable.ip = "random text here"
    refute_valid @validatable
  end
end
