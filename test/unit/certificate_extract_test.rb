require 'test_helper'

class CertificateExtractTest < ActiveSupport::TestCase
  context 'PEM encoded file' do
    def setup
      cert_raw = File.read(Rails.root.join('test/static_fixtures/certificates/example.com.crt'))
      @certificate = CertificateExtract.new(cert_raw)
    end

    test "it extracts the certificate's subject" do
      assert_equal 'example.com', @certificate.subject
    end

    test "it extracts the certificate's subject alternative names" do
      expected_sans = [
        'www.example.com',
        'www.example.net',
        'www.example.org',
        '192.168.1.1',
        '2001:DB8:0:0:0:0:0:1',
      ]
      assert_equal expected_sans, @certificate.subject_alternative_names
    end
  end

  context 'single joined line from apache as a reverse proxy' do
    def setup
      cert_raw = File.read(Rails.root.join('test/static_fixtures/certificates/apache-reverse-proxy'))
      @certificate = CertificateExtract.new(cert_raw)
    end

    test "it extracts the certificate's subject" do
      assert_equal 'centos7-foreman-reverse-proxy.wisse.example.com', @certificate.subject
    end

    test "it extracts the certificate's subject alternative names" do
      expected_sans = [
        'centos7-foreman-reverse-proxy.wisse.example.com',
        'puppet',
        'puppet.wisse.example.com',
      ]
      assert_equal expected_sans, @certificate.subject_alternative_names
    end
  end
end
