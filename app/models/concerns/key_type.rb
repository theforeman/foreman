module KeyType
  extend ActiveSupport::Concern
  KEY_TYPES = [N_("string"), N_("boolean"), N_("integer"), N_("real"), N_("array"), N_("hash"), N_("yaml"), N_("json")]

  included do
    validates :key_type, :inclusion => {:in => KEY_TYPES, :message => N_("invalid")}, :allow_blank => true, :allow_nil => true

    alias_attribute :parameter_type, :key_type
  end

  module ClassMethods
    def format_value_before_type_cast(val, key_type)
      return val if val.nil? || val.contains_erb?
      if key_type.present?
        case key_type.to_sym
          when :json, :array
            val = JSON.dump(val)
          when :yaml, :hash
            val = YAML.dump val
            val.sub!(/\A---\s*$\n/, '')
        end
      end
      val
    end
  end
end
