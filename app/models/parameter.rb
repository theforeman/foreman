class Parameter < ActiveRecord::Base
  validates_presence_of :name, :value
end
