class Parameter < ActiveRecord::Base
  belongs_to :host
  validates_presence_of :name, :value
  validates_associated :host
  
end
