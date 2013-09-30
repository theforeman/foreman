require 'test_helper'
require 'net'

class ValidationsTest < ActiveSupport::TestCase
  include Net::Validations

  test "mac address should be valid" do
    assert_nothing_raised Net::Validations::Error do
      validate_mac "aa:bb:cc:dd:ee:ff"
    end
  end

  test "mac should be invalid" do
    assert_raise Net::Validations::Error do
      validate_mac "abc123asdas"
    end
  end

  describe "mac normalization" do

    let(:mac) { "aa:bb:cc:dd:ee:ff" }

    test "should normalize dash separated format" do
      Net::Validations.normalize_mac("aa-bb-cc-dd-ee-ff").must_equal(mac)
    end

    test "should normalize condensed format" do
      Net::Validations.normalize_mac("aabbccddeeff").must_equal(mac)
    end

    test "should keep colon separated format" do
      Net::Validations.normalize_mac("aa:bb:cc:dd:ee:ff").must_equal(mac)
    end

  end

end
