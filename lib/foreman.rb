module Foreman
  # generate a UUID
  def self.uuid
    UUIDTools::UUID.random_create.to_s
  end
end
