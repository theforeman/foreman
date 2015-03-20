module Encryptable
  extend ActiveSupport::Concern

  included do
    ENCRYPTION_PREFIX = "encrypted-"
    before_save :encrypt_setters
  end

  module ClassMethods
    def encrypts(*fields)
      class_attribute :encryptable_fields
      self.encryptable_fields = fields.map(&:to_sym)
      define_getter_in_db(fields.map(&:to_sym))
      define_auto_decrypt_getter(fields.map(&:to_sym))
    end

    def encrypts?(field)
      encryptable_fields.include?(field.to_sym)
    end

    private

    def define_getter_in_db(fields)
      fields.each do |field|
        define_method "#{field}_in_db" do
          read_attribute(field.to_sym)
        end
      end
    end

    def define_auto_decrypt_getter(fields)
      fields.each do |field|
        define_method field do
          decrypt_field(send("#{field}_in_db".to_sym))
        end
      end
    end
  end

  def encrypt_setters
    self.encryptable_fields.each do |field|
      if send("#{field}_changed?")
        self.send("#{field}=", encrypt_field(read_attribute(field.to_sym)))
      end
    end
  end

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
    encryptor = ActiveSupport::MessageEncryptor.new(encryption_key)
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
    encryptor = ActiveSupport::MessageEncryptor.new(encryption_key)
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
end
