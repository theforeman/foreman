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

  test "hostname should be valid" do
    assert_nothing_raised Net::Validations::Error do
      validate_hostname "this.is.an.example.com"
    end
    assert_nothing_raised Net::Validations::Error do
      validate_hostname "this-is.an.example.com"
    end
    assert_nothing_raised Net::Validations::Error do
      validate_hostname "localhost"
    end
  end

  test "hostname should not be valid" do
    assert_raise Net::Validations::Error do
      validate_hostname "-this.is.a.bad.example.com"
    end
    assert_raise Net::Validations::Error do
      validate_hostname "this_is_a_bad.example.com"
    end
  end

  describe "hostname normalization" do
    let(:hostname) { "this.is.an.example.com" }

    test "should normalize incorrect case" do
      Net::Validations.normalize_hostname("ThIs.Is.An.eXaMPlE.CoM").must_equal(hostname)
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
