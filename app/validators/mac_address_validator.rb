class MacAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    make_invalid(record, attribute) unless Net::Validations.validate_mac(value)
  rescue Net::Validations::Error
    make_invalid(record, attribute)
  end

  def make_invalid(record, attribute)
    # error message can already be present from the Net::Validations::normalize_mac method
    if record.errors[attribute].blank?
      record.errors.add(attribute, (options[:message] || _("is not a valid MAC address")))
    end
    false
  end
end
