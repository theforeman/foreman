module EncryptValue
  ENCRYPTION_PREFIX = "encrypted-"
  def matches_prefix?(str)
    str.to_s.start_with? ENCRYPTION_PREFIX
  end

  def encryption_key
    return ENV['ENCRYPTION_KEY'] if ENV['ENCRYPTION_KEY'].present?
    return EncryptionKey::ENCRYPTION_KEY if defined? EncryptionKey::ENCRYPTION_KEY
    nil
  end

  def is_encryptable?(str)
    encryption_key.present? && str.present? && !matches_prefix?(str)
  end

  def is_decryptable?(str)
    encryption_key.present? && matches_prefix?(str)
  end

  def encrypt_field(str)
    return str unless is_encryptable?(str)
    begin
      # add prefix to encrypted string
      str_encrypted = "#{ENCRYPTION_PREFIX}#{encryptor.encrypt_and_sign(str)}"
      str = str_encrypted
    rescue => e
      puts_and_logs("At least one field encryption failed: #{e}") unless defined?(@@encrypt_err_reported) && @@encrypt_err_reported
      @@encrypt_err_reported = true
    end
    str
  end

  def decrypt_field(str)
    return str unless is_decryptable?(str)
    begin
      # remove prefix before decrypting string
      str_no_prefix = str.gsub(/^#{ENCRYPTION_PREFIX}/, "")
      str_decrypted = encryptor.decrypt_and_verify(str_no_prefix)
      str = str_decrypted
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      puts_and_logs("At least one field decryption failed, check ENCRYPTION_KEY") unless defined?(@@decrypt_err_reported) && @@decrypt_err_reported
      @@decrypt_err_reported = true
    end
    str
  end

  def self.reset_warnings
    @@decrypt_err_reported = false
    @@encrypt_err_reported = false
  end

  private

  def puts_and_logs(msg, level = Logger::WARN)
    logger.add level, msg
    puts msg if Foreman.in_rake? && !Rails.env.test? && level >= Logger::WARN
  end

  def encryptor
    full_key = encryption_key

    # Pass a limited length encryption key as Ruby's OpenSSL bindings will either raise an
    # exception for a mis-sized key or it will be silently truncated.
    #
    # Pass a full length signature key though, so pre-existing encrypted data can still be verified
    # against a key that is longer than the necessary encryption key.
    ActiveSupport::MessageEncryptor.new(full_key[0, ActiveSupport::MessageEncryptor.key_len], full_key)
  end
end
