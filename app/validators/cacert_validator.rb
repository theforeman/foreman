class CacertValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    Foreman::Util.ssl_cert_store(value)
  rescue OpenSSL::X509::StoreError => e
    message = _('is not a valid CA certificate')
    Foreman::Logging.exception(message, e)
    record.errors.add(attribute, message)
  end
end
