class UrlSchemaValidator < ActiveModel::EachValidator
  def initialize(args)
    @schemas = args[:in]
    super
  end

  def validate_each(record, attribute, value)
    unless value =~ /\A#{URI.regexp(@schemas)}\z/
      error_message = _('URL must be valid and schema must be one of %s') %
        @schemas.to_sentence
      record.errors.add(attribute, error_message)
    end
  end
end
