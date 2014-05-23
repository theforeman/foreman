class MacAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless Net::Validations.valid_mac? value
      record.errors[attribute] << (options[:message] || _("is not a valid MAC address"))
    end
  end
end
