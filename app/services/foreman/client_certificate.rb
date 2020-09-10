module Foreman
  class ClientCertificate
    delegate :logger, to: :Rails
    attr_reader :request

    def initialize(request:)
      @request = request
    end

    def raw_cert_available?
      @raw_cert_available ||= request.ssl? && raw_data.present? && raw_data != '(null)'
    end

    def raw_data
      request.env[certificate_env_key]
    end

    def subject
      return certificate_extract.subject if raw_cert_available?
      dn = request.env[dn_key]
      return unless dn && dn =~ /CN=([^\s\/,]+)/i

      Regexp.last_match(1).downcase
    end

    def subject_alternative_names
      return unless raw_cert_available?
      certificate_extract.subject_alternative_names
    end

    def verify
      request.env[verify_key]
    end

    def verified?
      return true if verify == 'SUCCESS'
      logger.info { "Client certificate is invalid: #{verify}" }
      false
    end

    def hosts
      return subject_alternative_names if subject_alternative_names.present?
      return [subject] if subject.present?
      []
    end

    private

    def certificate_env_key
      Setting[:ssl_client_cert_env]
    end

    def verify_key
      Setting[:ssl_client_verify_env]
    end

    def dn_key
      Setting[:ssl_client_dn_env]
    end

    def certificate_extract
      @certificate_extract ||= CertificateExtract.new(raw_data)
    end
  end
end
