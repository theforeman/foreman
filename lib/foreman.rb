module Foreman
  # generate a UUID
  def self.uuid
    UUIDTools::UUID.random_create.to_s
  end

  UUID_REGEXP = Regexp.new("^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-" +
                           "([0-9a-f]{2})([0-9a-f]{2})-([0-9a-f]{12})$")
  # does this look like a UUID?
  def self.is_uuid?(str)
    !!(str =~ UUID_REGEXP)
  end
end
