class Parameter < ActiveRecord::Base
  acts_as_audited
  validates_presence_of :name, :value
end
