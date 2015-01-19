require 'test_helper'
require 'net'

class ValidationsTest < ActiveSupport::TestCase
  include Net::Validations

  describe "valid_mac?" do
    test "nil is not valid" do
      Net::Validations.valid_mac?(nil).must_be_same_as false
    end

    test "48-bit MAC address is valid" do
      Net::Validations.valid_mac?("aa:bb:cc:dd:ee:ff").must_be_same_as true
    end

    test "64-bit MAC address is valid" do
      Net::Validations.valid_mac?("aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd").must_be_same_as true
    end

    test "MAC address is not valid" do
      Net::Validations.valid_mac?("aa:bb:cc:dd:ee").must_be_same_as false
      Net::Validations.valid_mac?("aa:bb:cc:dd:ee:ff:gg:11").must_be_same_as false
      Net::Validations.valid_mac?("aa:bb:cc:dd:ee:zz").must_be_same_as false
    end
  end

  test "48-bit mac address should be valid" do
    assert_nothing_raised Net::Validations::Error do
      validate_mac "aa:bb:cc:dd:ee:ff"
    end
  end

  test "64-bit mac address should be valid" do
    assert_nothing_raised Net::Validations::Error do
      validate_mac "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd"
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
    context "when 48-bit MAC address" do
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

    context "when 64-bit MAC address" do
      let(:mac) { "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd" }

      test "should normalize dash separated format" do
        Net::Validations.normalize_mac("aa-bb-cc-dd-ee-ff-00-11-22-33-44-55-66-77-88-99-aa-bb-cc-dd").must_equal(mac)
      end

      test "should normalize condensed format" do
        Net::Validations.normalize_mac("aabbccddeeff00112233445566778899aabbccdd").must_equal(mac)
      end

      test "should keep colon separated format" do
        Net::Validations.normalize_mac("aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd").must_equal(mac)
      end
    end

    context "when invalid MAC address" do
      test "should handle invalid MAC address length" do
        assert_raise ArgumentError do
          Net::Validations.normalize_mac("aa:bb:cc:dd:ee:ff:gg:11")
        end
      end

      test "should handle invalid MAC address characters" do
        assert_raise ArgumentError do
          assert_nil Net::Validations.normalize_mac("aa:bb:cc:dd:ee:zz")
        end
      end
    end
  end
end
