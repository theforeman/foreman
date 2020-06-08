class StoredValue < ApplicationRecord
  scope :valid, lambda {
    where(["expire_at > ?", Time.now]).or(where(expire_at: nil))
  }
  scope :expired, ->(ago = 0) { where(["expire_at <= ?", (Time.now - ago)]) }

  def self.write(result_key, result_value, expire_at: nil)
    record = find_by(key: result_key) || new(key: result_key)
    record.value = result_value
    record.expire_at = expire_at
    record.save
  end

  def self.read(result_key)
    record = valid.find_by(key: result_key)
    record&.value&.force_encoding('UTF-8')
  end
end
