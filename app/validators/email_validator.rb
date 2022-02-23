class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.empty?
    record.errors.add(attribute, _("is too long (maximum is 254 characters)")) if value && value.length > 254
    begin
      address = value.split("@")
      encoded_address = (address.count == 2) ? Mail::Encodings.decode_encode(address[0], :encode) + '@' + Mail::Encodings.decode_encode(address[1], :encode) : value
      m = Mail::Address.new(encoded_address)
      r = m.domain.present? && m.address == value
    rescue Mail::Field::ParseError => exception
      Foreman::Logging.exception("Email address is invalid", exception)
      r = false
    end
    record.errors.add(attribute, (options[:message] || N_("is invalid"))) unless r
  end
end
