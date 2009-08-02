class Puppetclass < ActiveRecord::Base
  has_and_belongs_to_many :environments
  has_and_belongs_to_many :operatingsystems
  has_and_belongs_to_many :hosts

  validates_uniqueness_of :name
  validates_presence_of :name
end
