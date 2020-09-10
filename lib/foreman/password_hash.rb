require 'active_support/core_ext/module/delegation'

#
# Generic-purpose password hasher with two implementations: BCrypt and SHA1.
#
# generate_salt(cost) - generates random salt of optional cost (1-30)
# calculate_salt(object, cost) - calculates hash from given object (useful for tokens)
# hash_secret(password, salt) - returns hash from secret and salt
#
module Foreman
  class PasswordHash
    class BCryptImplementation
      def generate_salt(cost)
        BCrypt::Engine.generate_salt(cost)
      end

      def calculate_salt(object, cost)
        "$2a$#{cost.to_s.rjust(2, '0')}$#{Digest::SHA1.hexdigest(object.to_s)}"
      end

      def hash_secret(password, salt)
        BCrypt::Engine.hash_secret(password, salt)
      rescue BCrypt::Errors::InvalidSalt
        # bcrypt expects '$2a$nn$minimum22characters'
        raise(Foreman::Exception.new(N_("BCrypt salt '%s' is invalid"), salt))
      end
    end

    class SHA1Implementation
      def generate_salt(cost)
        Digest::SHA1.hexdigest([Time.now.utc, rand].join)
      end

      def calculate_salt(object, cost)
        Digest::SHA1.hexdigest(object.to_s)
      end

      def hash_secret(password, salt)
        Digest::SHA1.hexdigest([password, salt].join)
      end
    end

    def initialize(implementation = :bcrypt)
      if implementation == :bcrypt
        @implementation = BCryptImplementation.new
      elsif implementation == :sha1
        @implementation = SHA1Implementation.new
      else
        raise(Foreman::Exception.new(N_("Unknown password hash method: %s"), implementation))
      end
    end

    def self.detect_implementation(password_string)
      password_string.start_with?('$2') ? :bcrypt : :sha1
    end

    delegate :generate_salt, :calculate_salt, :hash_secret, to: :implementation

    private

    attr_reader :implementation
  end
end
