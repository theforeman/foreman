class DomainNameValidator < ActiveModel::EachValidator
  # Validate domain name is a valid host name according to RFC 1123 section 2.1.
  # Before validation the name should be down-cased and puny-coded if needed.
  def validate_each(record, attribute, value)
    record.errors.add(attribute, _("is not a valid domain name")) unless value =~ /\A[a-z0-9][a-z0-9\-]{0,62}(\.[a-z0-9][a-z0-9\-]{0,62})*\Z/
    record.errors.add(attribute, _("is too long for a domain name")) if value.length > 255
  end
end
