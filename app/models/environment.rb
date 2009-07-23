class Environment < ActiveRecord::Base
  has_and_belongs_to_many :hosttypes
end
