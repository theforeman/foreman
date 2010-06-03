class Hostgroup < ActiveRecord::Base
  has_and_belongs_to_many :puppetclasses
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white spaces."
  has_many :group_parameters, :dependent => :destroy
  accepts_nested_attributes_for :group_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  has_many :hosts
  before_destroy Ensure_not_used_by.new(:hosts)
  default_scope :order => 'name'

  acts_as_audited

#TODO: add a method that returns the valid os for a hostgroup

 def all_puppetclasses
   puppetclasses
 end

 def hostgroup
   self
 end

end
