class PuppetLookupValue < LookupValue
  attr_accessible :use_puppet_default
  validate :puppet_lookup_key?
  validate :value_present?

  private

  def puppet_lookup_key?
    lookup_key.puppet?
  end

  def value_present?
    errors.add(:value, :blank) if value.to_s.empty? and !use_puppet_default
  end
end
