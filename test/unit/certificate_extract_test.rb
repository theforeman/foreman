require 'test_helper'

class CertificateExtractTest < ActiveSupport::TestCase
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
      '2001:DB8:0:0:0:0:0:1'
    ]
    assert_equal expected_sans, @certificate.subject_alternative_names
  end
end
