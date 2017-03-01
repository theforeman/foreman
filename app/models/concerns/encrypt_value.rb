module EncryptValue
  ENCRYPTION_PREFIX = "encrypted-"
  def matches_prefix?(str)
    ENCRYPTION_PREFIX == str.to_s[0..(ENCRYPTION_PREFIX.length - 1)]
  end

  def encryption_key
    return ENV['ENCRYPTION_KEY'] if ENV['ENCRYPTION_KEY'].present?
    return EncryptionKey::ENCRYPTION_KEY if defined? EncryptionKey::ENCRYPTION_KEY
    nil
  end

  def is_encryptable?(str)
    if !encryption_key.present?
      puts_and_logs "Missing ENCRYPTION_KEY configuration, so #{self.class.name} #{name} could not be encrypted", Logger::WARN
      false
    elsif str.blank?
      puts_and_logs "String is blank', so #{self.class.name} #{name} was not encrypted", Logger::DEBUG
      false
    elsif matches_prefix?(str)
      puts_and_logs "String starts with the prefix '#{ENCRYPTION_PREFIX}', so #{self.class.name} #{name} was not encrypted again", Logger::DEBUG
      false
    else
      true
    end
  end

  def is_decryptable?(str)
    if !matches_prefix?(str)
      puts_and_logs "String does not start with the prefix '#{ENCRYPTION_PREFIX}', so #{self.class.name} #{name} was not decrypted", Logger::DEBUG
      false
    elsif !encryption_key.present?
      puts_and_logs "Missing ENCRYPTION_KEY configuration, so #{self.class.name} #{name} could not be decrypted", Logger::WARN
      false
    else
      true
    end
  end

  def encrypt_field(str)
    return str unless is_encryptable?(str)
    begin
      # add prefix to encrypted string
      str_encrypted = "#{ENCRYPTION_PREFIX}#{encryptor.encrypt_and_sign(str)}"
      puts_and_logs "Successfully encrypted field for #{self.class.name} #{name}"
      str = str_encrypted
    rescue
      puts_and_logs "WARNING: Encryption failed for string. Please check that the ENCRYPTION_KEY has not changed.", Logger::WARN
    end
    str
  end

  def decrypt_field(str)
    return str unless is_decryptable?(str)
    begin
      # remove prefix before decrypting string
      str_no_prefix = str.gsub(/^#{ENCRYPTION_PREFIX}/, "")
      str_decrypted = encryptor.decrypt_and_verify(str_no_prefix)
      puts_and_logs "Successfully decrypted field for #{self.class.name} #{name}"
      str = str_decrypted
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      puts_and_logs "WARNING: Decryption failed for string. Please check that the ENCRYPTION_KEY has not changed.", Logger::WARN
    end
    str
  end

  private

  def puts_and_logs(msg, level = Logger::INFO)
    logger.add level, msg
    puts msg if Foreman.in_rake? && !Rails.env.test? && level >= Logger::INFO
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
