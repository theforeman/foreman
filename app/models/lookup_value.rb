class LookupValue < ActiveRecord::Base
  belongs_to :lookup_key
#  validates_uniqueness_of :priority, :scope => :value
  validates_presence_of :priority, :value

  attr_accessor :should_destroy

  def should_destroy?
    should_destroy.to_i == 1
  end
end
