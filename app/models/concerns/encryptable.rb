module Encryptable
  extend ActiveSupport::Concern
  include EncryptionKey if defined?(EncryptionKey)
  # Set encryption key for tests only if case it's not set
  ENCRYPTION_KEY = '25d224dd383e92a7e0c82b8bf7c985e815f34cf5' if Rails.env.test?

  if const_defined?(:ENCRYPTION_KEY)

    included do
      ENCRYPTION_PREFIX = "encrypted-"
      before_save :encrypt_setters
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

    def puts_and_logs(msg)
      logger.info msg
      puts msg if Foreman.in_rake? && !Rails.env.test?
    end

    def is_encryptable?(str)
      return true if !matches_prefix?(str) && str.present?
      if str.blank?
        puts_and_logs "String is empty', so #{self.class.name} #{name} was not encrypted"
      else
        puts_and_logs "String starts with the prefix '#{ENCRYPTION_PREFIX}', so #{self.class.name} #{name} was not encrypted again"
      end
      false
    end

    def is_decryptable?(str)
      return true if matches_prefix?(str)
      puts_and_logs "String does not start with the prefix '#{ENCRYPTION_PREFIX}', so #{self.class.name} #{name} was not decrypted"
      false
    end

    def encrypt_field(str)
      return str.to_s unless is_encryptable?(str)
      encryptor = ActiveSupport::MessageEncryptor.new(ENCRYPTION_KEY)
      begin
        # add prefix to encrypted string
        str_encrypted = "#{ENCRYPTION_PREFIX}#{encryptor.encrypt_and_sign(str)}"
        puts_and_logs "Successfully encrypted field for #{self.class.name} #{name}"
        str = str_encrypted
      rescue
        puts_and_logs "WARNING: Encryption failed for string. Please check that the ENCRYPTION_KEY has not changed."
      end
      str
    end

    def decrypt_field(str)
      return str unless is_decryptable?(str)
      encryptor = ActiveSupport::MessageEncryptor.new(ENCRYPTION_KEY)
      begin
        # remove prefix before decrypting string
        str_no_prefix = str.gsub(/^#{ENCRYPTION_PREFIX}/, "")
        str_decrypted = encryptor.decrypt_and_verify(str_no_prefix)
        puts_and_logs "Successfully decrypted field for #{self.class.name} #{name}"
        str = str_decrypted
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        puts_and_logs "WARNING: Decryption failed for string. Please check that the ENCRYPTION_KEY has not changed."
      end
      str
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

  else
    included do
      logger.info "ENCRYPTION_KEY is not defined, so encryption is turned off for #{model_name}."
    end

    module ClassMethods
      def encrypts(*fields)
      end
    end
  end
end
