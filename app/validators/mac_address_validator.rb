class MacAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless Net::Validations.valid_mac?(value)
      make_invalid(record, attribute)
    end
  rescue Net::Validations::Error
    make_invalid(record, attribute)
  end

  def make_invalid(record, attribute)
    record.errors[attribute] << (options[:message] || _("is not a valid MAC address"))
    false
  end
end
