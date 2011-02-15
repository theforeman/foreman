class Feature < ActiveRecord::Base
  has_and_belongs_to_many :smart_proxies
  validates_presence_of :name
end
