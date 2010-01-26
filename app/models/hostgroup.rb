class Hostgroup < ActiveRecord::Base
  has_and_belongs_to_many :puppetclasses
  validates_uniqueness_of :name
  has_many :group_parameters, :dependent => :destroy
  has_many :hosts


#TODO: add a method that returns the valid os for a hostgroup

 def to_s
   name
 end
end
