module PuppetLookupValueExtensions
  extend ActiveSupport::Concern

  included do
    validate :value_present?
  end

  def value_present?
    errors.add(:value, :blank) if value.to_s.empty? && !omit && lookup_key.puppet?
  end
end
