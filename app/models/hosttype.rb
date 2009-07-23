class Hosttype < ActiveRecord::Base
  has_many :hosts
  has_and_belongs_to_many :operatingsystems
  has_and_belongs_to_many :environments
  has_many :medias, :through => :operatingsystems
  has_many :architectures, :through => :operatingsystems
  validates_uniqueness_of :name
  validates_presence_of :name

end
