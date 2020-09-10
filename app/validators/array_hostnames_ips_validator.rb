# validates hostnames, IPv4, IPv6 and subnets
class ArrayHostnamesIpsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, _("must contain valid hostnames") unless value.all? do |item|
      item.to_s.match(URI::HOST) || (IPAddr.new(item.to_s) rescue nil)
    end
  end
end
