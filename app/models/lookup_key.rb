class LookupKey < ActiveRecord::Base
  has_many :lookup_values
  validates_uniqueness_of :key
  validates_presence_of :key
  after_update :save_values
  validates_associated :lookup_values

  def self.search(key,order = [])
    return false unless (k = find_by_key(key))
    order.each do |prio|
      v = k.lookup_values.first(:conditions => {:priority => prio})
      return v.value if v
    end
    # nothing was found
    return false
  end

  def value_attributes=(value_attributes)
    value_attributes.each do |attributes|
      if attributes[:id].blank?
        lookup_values.build(attributes)
      else
        value = lookup_values.detect {|v| v.id == attributes[:id].to_i }
        value.id = attributes[:id]
        attributes.delete("id")
        value.attributes = attributes
      end
    end
  end

  def save_values
    lookup_values.each do |v|
      if v.should_destroy?
        v.destroy
      else
        v.save(false)
      end
    end
  end
end
