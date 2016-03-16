require 'resolv'

class IpRegexpValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, _("must be a valid IP regexp") unless is_ok(value)
  end

  def is_ok(value)
    value.split('|').map { |ip| ip.match Resolv::AddressRegex }.all?
  end
end
