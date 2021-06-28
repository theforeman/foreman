class HttpUrlValidator < ActiveModel::EachValidator
  include UrlValidation

  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.empty?

    if value.empty? || !is_http_url?(value)
      record.errors.add(attribute, _("Invalid HTTP(S) URL"))
    end
  end
end
