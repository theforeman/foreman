class UrlValidator < ActiveModel::EachValidator
  def initialize(options)
    options.reverse_merge!(schemes: %w(http https))
    options.reverse_merge!(message: _('URL must be valid and scheme must be one of %s') %
                           options[:schemes].to_sentence)
    super(options)
  end

  def validate_each(record, attribute, value)
    schemes = Array.wrap(options[:schemes]).map(&:to_s)
    scheme = URI.parse(value).scheme

    record.errors.add(attribute, options[:message]) unless schemes.include?(scheme)
  rescue URI::InvalidURIError
    record.errors.add(attribute, options[:message])
  end
end
