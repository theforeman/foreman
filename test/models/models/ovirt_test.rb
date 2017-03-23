require 'test_helper'

module Models
  class OvirtTest < ActiveSupport::TestCase
    setup do
      User.current = users :admin
    end

    test "#new_volume should respect preallocate flag" do
      ovirt = Foreman::Model::Ovirt.new
      volume = ovirt.new_volume(:preallocate => '1')
      assert_equal 'false', volume.sparse
      assert_equal 'raw', volume.format

      volume = ovirt.new_volume(:preallocate => '0')
      assert_equal 'true', volume.sparse

      volume = ovirt.new_volume
      assert_equal 'true', volume.sparse
    end

    test "accepts multiple certificates" do
      ovirt = Foreman::Model::Ovirt.new
      cert1 = "-----BEGIN CERTIFICATE-----\r\nMIICvzCCAaegAwIBAgIBADANBgkqhkiG9w0BAQUFADAjMRQwEgYDVQQDDAtleGFt\r\n" +
              "cGxlLmNvbTELMAkGA1UEBhMCRUUwHhcNMTcwMzIzMTEwMzM0WhcNMTgwMzIzMTEw\r\nMzM0WjAjMRQwEgYDVQQDDAtleGFtcGxlLmNvbTELMAkGA1UEBhMCRUUwggEiMA0G\r\n" +
              "CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCv46BMxn4Ddofw5/NqaOMLPU/mEC5t\r\nF9dh9wUIRsbJncOEtj0GFo9gATe2Lg6pVHkdffhZX1MdlboHsJC1jtJPo59G9HI6\r\n" +
              "HsebUPo9tQB0t5JR54lD3FipxR8QZ79mS/5UaGeze5qzQS/HpIQ1N9HWGYawtyCV\r\n3qy+R+TYNQREQw64tWYJix+H32kS4T+aU3EbzM8rK6+4ZHwrPAoqT8Dy092W7Uys\r\n" +
              "ty7T6zbGmcb+mUN6Zaumej0mP5UET8b4jfJDsvq3L2b3eih6O64OQJnYj+tKxnvV\r\nSFyoZQyTB7OKBlXrCH/wl0l5jtXdDmysQjPtJq+fiV//rKqf/iUMv+kXAgMBAAEw\r\n" +
              "DQYJKoZIhvcNAQEFBQADggEBAEdVQJM42CfkffBvIWDtutreGMUk3cTl+WRXvvcc\r\n29LJ5iQCkzJ3ouXryi8Fucd4s4HFrSUPpI6srWYjMWVQf2wqdPYo8Q8FJ3WdULLk\r\n" +
              "ZQ76KW+HkebPSSwEveWwzH/s9WQP0g6Q9tIFA/Lwmu6+xGeJCBh0etTw0r3eNnGb\r\n4dHVzxN9FLCP35aM6JOU4Fenr8eYJrqKlUNryMCcaTc05iWQOJgeIdfDv/zAEKM+\r\n" +
             "DLwBorpFdhaNPZIAqCraARErzhu0w1Gqt2YCI0xx+reuKCGUV5C6q3i2dRsIMaIq\r\n+sqd9n/nJdZ0UDLSePNTPgI3Zu8xkEFej0sPA5Hh0gTuz1E=\r\n-----END CERTIFICATE-----"
      cert2 = "-----BEGIN CERTIFICATE-----\r\nMIICgjCCAeugAwIBAgIBADANBgkqhkiG9w0BAQUFADA6MQswCQYDVQQGEwJCRTEN\r\n" +
              "MAsGA1UECgwEVGVzdDENMAsGA1UECwwEVGVzdDENMAsGA1UEAwwEVGVzdDAeFw0x\r\nNzAzMjYxMjE5MDhaFw0xODAzMjYxMjE5MDhaMDoxCzAJBgNVBAYTAkJFMQ0wCwYD\r\n" +
              "VQQKDARUZXN0MQ0wCwYDVQQLDARUZXN0MQ0wCwYDVQQDDARUZXN0MIGfMA0GCSqG\r\nSIb3DQEBAQUAA4GNADCBiQKBgQDYTqEtMNFJj2AyDPAer0T5tx1fNfZKIWHYpeQ4\r\n" +
              "bGqC+4MOS/mDuLgR6/xfm2TEx+Ii5cD1ekEXwV5rH+EXNSkm+zeF3NBxbw3saSGN\r\n8fzvySyImhjnpG9+FIhxJmvjnwIbvhsAqoB8AE/kyv0Hpvt9G/4Nc2to8723QMtw\r\n" +
              "VP5uIQIDAQABo4GXMIGUMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFCLMJ5XZ\r\nLnN3HUoKCP6dkhzcr1+mMGIGA1UdIwRbMFmAFCLMJ5XZLnN3HUoKCP6dkhzcr1+m\r\n" +
              "oT6kPDA6MQswCQYDVQQGEwJCRTENMAsGA1UECgwEVGVzdDENMAsGA1UECwwEVGVz\r\ndDENMAsGA1UEAwwEVGVzdIIBADANBgkqhkiG9w0BAQUFAAOBgQB6hIeXES65mbvm\r\n" +
              "nQpO5TbKVfJbmzT6y+hrI4qQfe4IlZBoZb4r69yjz2zUuPwh16UyTPvyIZz5rYsT\r\n9WiKC8EmTdvr49V/3w5slzPGjOKXGF/qaQMACtdeDz4jxBqJHwiSj34CBkerU21c\r\nXUw+9jVgOOsA47OYnFoEehB2Us+Euw==\r\n-----END CERTIFICATE-----"
      store = ovirt.send(:ca_cert_store, cert1 + "\r\n" + cert2)
      assert store.verify(OpenSSL::X509::Certificate.new(cert1))
      assert store.verify(OpenSSL::X509::Certificate.new(cert2))
    end
  end
end
