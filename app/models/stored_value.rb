# This class represents temporary storage for values processed in background.
# This is a database solution, wich should not be the only one, as it has many limitations.
class StoredValue < ApplicationRecord
  scope :valid, lambda {
    f = arel_table[:expire_at]
    where(f.eq(nil).or(f.gteq(Time.now)))
  }

  scope :expired, ->(ago = 0) { where(arel_table[:expire_at].lteq(Time.now - ago)) }

  def self.write(result_key, result_value, expire_at: nil)
    record = self.find_by(key: result_key) || new(key: result_key)
    record.value = result_value
    record.expire_at = expire_at
    record.save
  end

  def self.read(result_key)
    record = self.valid.find_by(key: result_key)
    record&.value
  end
end
