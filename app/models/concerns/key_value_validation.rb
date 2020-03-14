module KeyValueValidation
  extend ActiveSupport::Concern

  def validate_and_cast_value(object_for_key_type = nil)
    object_for_key_type ||= self
    return if !value.is_a?(String) || value.contains_erb?
    Foreman::Parameters::Caster.new(self, :attribute_name => :value, :to => object_for_key_type.key_type).cast!
  rescue StandardError, SyntaxError => e
    Foreman::Logging.exception("Error while parsing #{object_for_key_type}", e)
    errors.add(:value, _("is invalid %s") % object_for_key_type.key_type)
  end
end
