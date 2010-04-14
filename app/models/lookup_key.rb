class LookupKey < ActiveRecord::Base
  has_many :lookup_values
  accepts_nested_attributes_for :lookup_values, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  validates_uniqueness_of :key
  validates_presence_of :key
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

end
