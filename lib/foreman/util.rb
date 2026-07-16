require 'securerandom'

module Foreman
  module Util
    # searches for binaries in predefined directories and user PATH
    # accepts a binary name and an array of paths to search first
    # if path is omitted will search only in user PATH
    def which(bin, *path)
      path += ENV['PATH'].split(File::PATH_SEPARATOR)
      path.flatten.uniq.each do |dir|
        dest = File.join(dir, bin)
        return dest if FileTest.file?(dest) && FileTest.executable?(dest)
      end
      false
    rescue StandardError => e
      logger.warn e
      false
    end

    # Generates a URL-safe token for use with Rails for signing cookies
    def secure_token
      SecureRandom.base64(96).tr('+/=', '-_*')
    end

    # recommended to make encryption_key 32 bytes, matching the key length preferred by
    # AS::MessageEncryptor's default algorithm
    def secure_encryption_key
      SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len / 2)
    end

    # Converts CRLF and CR line endings to LF.
    def self.normalize_line_endings(string)
      return string if string.blank?
      string.encode(string.encoding, universal_newline: true)
    end

    # Adds a ca cert bundle with multiple ca certs to a
    # OpenSSL::X509::Store certificate
    def self.add_ca_bundle_to_store(ca_bundle, cert_store)
      ca_bundle = normalize_line_endings(ca_bundle)
      Tempfile.open('cert.pem', Rails.root.join('tmp')) do |f|
        f.write(ca_bundle)
        f.flush
        cert_store.add_file(f.path)
      end
    end

    # OpenSSL certificate store for TLS verification.
    # With cacert set, uses only that PEM bundle (pinned; system CAs are not trusted).
    def self.ssl_cert_store(cacert = nil)
      return if cacert.blank?
      cert_store = OpenSSL::X509::Store.new
      add_ca_bundle_to_store(cacert, cert_store)
      cert_store
    end
  end
end
