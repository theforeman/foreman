module Encryptable
  extend ActiveSupport::Concern
  include EncryptValue
  included do
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
          self[field.to_sym]
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
    encryptable_fields.each do |field|
      if send("#{field}_changed?")
        send("#{field}=", encrypt_field(self[field.to_sym]))
      end
    end
  end
end
