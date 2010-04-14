class LookupValue < ActiveRecord::Base
  belongs_to :lookup_key
#  validates_uniqueness_of :priority, :scope => :value
  validates_presence_of :priority, :value

end
