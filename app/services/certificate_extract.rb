require 'openssl'

class CertificateExtract
  def initialize(cert)
    cert_raw = Base64.decode64(strip_cert(cert))
    @certificate = OpenSSL::X509::Certificate.new(cert_raw)
  end

  def subject
    @subject ||= @certificate.subject.to_s[/CN=([^\s\/,]+)/i, 1]
  end

  def subject_alternative_names
    @subject_alternative_names || begin
      @subject_alternative_names = []
      if subject_alt_name_extension
        _id, ostr = OpenSSL::ASN1.decode(subject_alt_name_extension).value
        sequence = OpenSSL::ASN1.decode(ostr.value)
        sequence.value.each do |san|
          @subject_alternative_names << san.value if san.tag == 2 # dNSName in RFC5280
          if san.tag == 7 # iPAddress in RFC5280
            @subject_alternative_names << san.value.unpack('C*').join('.') if san.value.size == 4 # IPv4
            @subject_alternative_names << san.value.unpack('n*').map { |e| sprintf("%X", e) }.join(':') if san.value.size == 16 # IPv6
          end
        end
      end
      @subject_alternative_names
    end
  end

  def subject_alt_name_extension
    @certificate.extensions.find { |e| e.oid == "subjectAltName" }
  end

  private

  def strip_cert(cert)
    cert.to_s.gsub("-----BEGIN CERTIFICATE-----", "").gsub("-----END CERTIFICATE-----", "").gsub(/\s+/, '')
  end
end
