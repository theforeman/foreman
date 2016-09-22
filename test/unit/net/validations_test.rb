require 'test_helper'
require 'net'

class ValidationsTest < ActiveSupport::TestCase
  describe "validate_mac" do
    test "nil is not valid" do
      Net::Validations.validate_mac(nil).must_be_same_as false
    end

    test "48-bit MAC address is valid" do
      Net::Validations.validate_mac("aa:bb:cc:dd:ee:ff").must_be_same_as true
    end

    test "64-bit MAC address is valid" do
      Net::Validations.validate_mac("aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd").must_be_same_as true
    end

    test "MAC address is not valid" do
      Net::Validations.validate_mac("aa:bb:cc:dd:ee").must_be_same_as false
      Net::Validations.validate_mac("aa:bb:cc:dd:ee:ff:gg:11").must_be_same_as false
      Net::Validations.validate_mac("aa:bb:cc:dd:ee:zz").must_be_same_as false
    end
  end

  test "48-bit mac address should be valid" do
    assert_nothing_raised do
      Net::Validations.validate_mac! "aa:bb:cc:dd:ee:ff"
    end
  end

  test "64-bit mac address should be valid" do
    assert_nothing_raised do
      Net::Validations.validate_mac! "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99:aa:bb:cc:dd"
    end
  end

  test "mac should be invalid" do
    assert_raise Net::Validations::Error do
      Net::Validations.validate_mac! "abc123asdas"
    end
  end

  describe 'multicast_mac?' do
    test 'MAC address is multicast' do
      assert_equal true, Net::Validations.multicast_mac?('13:61:f1:de:71:73')
    end

    test 'MAC address is not multicast' do
      assert_equal false, Net::Validations.multicast_mac?('3c:15:c2:d2:f4:60')
    end
  end

  describe 'broadcast_mac?' do
    test 'MAC address is broadcast' do
      assert_equal true, Net::Validations.broadcast_mac?('ff:ff:ff:ff:ff:ff')
    end

    test 'MAC address is not broadcast' do
      assert_equal false, Net::Validations.broadcast_mac?('3c:15:c2:d2:f4:60')
    end
  end

  test "hostname should be valid" do
    assert_nothing_raised do
      Net::Validations.validate_hostname! "this.is.an.example.com"
    end
    assert_nothing_raised do
      Net::Validations.validate_hostname! "this-is.an.example.com"
    end
    assert_nothing_raised do
      Net::Validations.validate_hostname! "localhost"
    end
  end

  test "hostname should not be valid" do
    assert_raise Net::Validations::Error do
      Net::Validations.validate_hostname! "-this.is.a.bad.example.com"
    end
    assert_raise Net::Validations::Error do
      Net::Validations.validate_hostname! "this_is_a_bad.example.com"
    end
  end

  describe "network validation" do
    test "network should be valid" do
      assert_nothing_raised do
        Net::Validations.validate_network! "123.1.123.1"
      end
    end

    test "network should not be valid" do
      assert_raise Net::Validations::Error do
        Net::Validations.validate_network! "invalid"
      end
      assert_raise Net::Validations::Error do
        Net::Validations.validate_network! "9999.99.12.1"
      end
    end
  end

  describe "mask validation" do
    test "mask should be valid" do
      assert_nothing_raised do
        Net::Validations.validate_mask! "255.255.255.0"
      end
    end

    test "mask should not be valid" do
      assert_raise Net::Validations::Error do
        Net::Validations.validate_mask! "22.222.22.2"
      end
      assert_raise Net::Validations::Error do
        Net::Validations.validate_mask! "invalid"
      end
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
        assert_raise Net::Validations::Error do
          Net::Validations.normalize_mac("aa:bb:cc:dd:ee:ff:gg:11")
        end
      end

      test "should handle invalid MAC address characters" do
        assert_raise Net::Validations::Error do
          assert_nil Net::Validations.normalize_mac("aa:bb:cc:dd:ee:zz")
        end
      end
    end
  end

  test "IPv4 address should be valid" do
    assert Net::Validations.validate_ip("127.0.0.1")
  end

  test "IPv4 address should be invalid" do
    refute Net::Validations.validate_ip("127.0.0.300")
  end

  test "empty IPv4 address should be invalid" do
    refute Net::Validations.validate_ip('')
  end

  test "nil should be invalid ip" do
    refute Net::Validations.validate_ip(nil)
  end

  test "return IP when IPv4 address is valid" do
    assert_nothing_raised do
      assert "127.0.0.1", Net::Validations.validate_ip!("127.0.0.1")
    end
  end

  test "raise error when IPv4 address is invalid" do
    assert_raise Net::Validations::Error do
      Net::Validations.validate_ip! "127.0.0.1.2"
    end
  end

  test "should normalize IPv4 address" do
    assert_equal "127.0.0.1", Net::Validations.normalize_ip("127.000.0.1")
  end

  test "should ignore invalid data when normalizing IPv4 address" do
    assert_equal "xyz.1.2.3", Net::Validations.normalize_ip("xyz.1.2.3")
  end

  test "should normalize IPv6 address" do
    assert_equal '2001:db8::1', Net::Validations.normalize_ip6('2001:0db8:0000:0000::0001')
  end

  test "should ignore invalid data when normalizing IPv6 address" do
    assert_equal 'invalid', Net::Validations.normalize_ip6('invalid')
  end
end
