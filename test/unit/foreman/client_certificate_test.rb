require 'test_helper'

class Foreman::ClientCertificateTest < ActiveSupport::TestCase
  let(:raw_certificate) { File.read(Rails.root.join('test/static_fixtures/certificates/example.com.crt')) }
  # Can be SUCCESS, GENEROUS or NONE
  let(:ssl_client_verify) { 'SUCCESS' }
  let(:ssl_client_dn) { '/CN=example.com/serialNumber=123456789012/DC=FOO/C=US' }
  let(:request) do
    OpenStruct.new(
      'ssl?': true,
      env: {
        'SSL_CLIENT_VERIFY' => ssl_client_verify,
        'SSL_CLIENT_CERT' => raw_certificate,
        'SSL_CLIENT_S_DN' => ssl_client_dn,
      }
    )
  end
  let(:client_certificate) { Foreman::ClientCertificate.new(request: request) }

  setup do
    Setting[:ssl_client_cert_env] = 'SSL_CLIENT_CERT'
    Setting[:ssl_client_dn_env] = 'SSL_CLIENT_S_DN'
    Setting[:ssl_client_verify_env] = 'SSL_CLIENT_VERIFY'
  end

  describe '#raw_cert_available?' do
    context 'no ssl request' do
      test 'raw client certificate not available' do
        request.public_send(:'ssl?=', false)
        assert_equal false, client_certificate.raw_cert_available?
      end
    end

    context 'without a certificate' do
      let(:raw_certificate) { nil }

      test 'raw client certificate is not available' do
        assert_equal false, client_certificate.raw_cert_available?
      end
    end

    context 'with a null certificate' do
      let(:raw_certificate) { '(null)' }

      test 'raw client certificate is not available' do
        assert_equal false, client_certificate.raw_cert_available?
      end
    end

    context 'with a certificate' do
      test 'raw client certificate is available' do
        assert_equal true, client_certificate.raw_cert_available?
      end
    end
  end

  describe '#verify' do
    context 'with SSL_CLIENT_VERIFY = SUCCESS' do
      test 'the client certificate is valid' do
        assert_equal true, client_certificate.verified?
      end
    end

    context 'with SSL_CLIENT_VERIFY = GENEROUS' do
      let(:ssl_client_verify) { 'GENEROUS' }

      test 'the client certificate is invalid' do
        assert_equal false, client_certificate.verified?
      end
    end

    context 'with SSL_CLIENT_VERIFY = NONE' do
      let(:ssl_client_verify) { 'NONE' }

      test 'the client certificate is invalid' do
        assert_equal false, client_certificate.verified?
      end
    end
  end

  describe '#subject' do
    context 'with a certificate' do
      test 'reads the subject from the certificate' do
        assert_equal 'example.com', client_certificate.subject
      end
    end

    context 'without a certificate' do
      let(:raw_certificate) { nil }

      test 'reads the subject from the SSL_CLIENT_S_DN header' do
        assert_equal 'example.com', client_certificate.subject
      end
    end
  end

  describe '#subject_alternative_names' do
    context 'with a certificate' do
      it 'reads the SANs from the certificate' do
        assert_equal ['www.example.com', 'www.example.net', 'www.example.org', '192.168.1.1', '2001:DB8:0:0:0:0:0:1'], client_certificate.subject_alternative_names
      end
    end

    context 'without a certificate' do
      let(:raw_certificate) { nil }

      it 'returns no SANs' do
        assert_nil client_certificate.subject_alternative_names
      end
    end
  end

  describe '#hosts' do
    context 'with a certificate' do
      it 'reads the SANs from the certificate' do
        assert_equal ['www.example.com', 'www.example.net', 'www.example.org', '192.168.1.1', '2001:DB8:0:0:0:0:0:1'], client_certificate.hosts
      end

      it 'falls back to the CN if no sans are present' do
        client_certificate.stubs(:subject_alternative_names).returns([])
        assert_equal ['example.com'], client_certificate.hosts
      end
    end

    context 'without a certificate' do
      let(:raw_certificate) { nil }

      it 'returns an empty list' do
        client_certificate.stubs(:subject)
        assert_equal [], client_certificate.hosts
      end
    end
  end
end
