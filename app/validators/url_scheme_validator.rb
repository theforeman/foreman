class URLSchemeValidator < ActiveModel::EachValidator
  def initialize(args)
    @schemes = args[:in]
    super
  end

  def validate_each(record, attribute, value)
    if value.blank?
      return if options[:allow_blank]
      record.errors.add(attribute, error_message)
      return
    end

    uri = URI.parse(value)
    unless @schemes.include?(uri.scheme) && uri.host.present?
      record.errors.add(attribute, error_message)
    end
  rescue URI::InvalidURIError
    record.errors.add(attribute, error_message)
  end

  private

  def error_message
    _('URL must be valid and scheme must be one of %s') %
      @schemes.to_sentence
  end
end

# Backward compatibility alias
URLSchemaValidator = URLSchemeValidator
