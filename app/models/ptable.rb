# This models the partition tables for a disk layouts
# It supports both static partition maps and dynamic scripts that create partition tables on-the-fly
# A host object may contain a reference to one of these ptables or, alternatively, it may contain a
# modified version of one of these in textual form
class Ptable < ActiveRecord::Base
  has_many :hosts
  has_and_belongs_to_many :operatingsystems
  before_destroy Ensure_not_used_by.new(:hosts)
  validates_uniqueness_of :name
  validates_uniqueness_of :layout
  validates_presence_of :layout
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white spaces."

  def to_s
    name
  end
end
