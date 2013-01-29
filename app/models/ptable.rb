# This models the partition tables for a disk layouts
# It supports both static partition maps and dynamic scripts that create partition tables on-the-fly
# A host object may contain a reference to one of these ptables or, alternatively, it may contain a
# modified version of one of these in textual form
class Ptable < ActiveRecord::Base
  include Authorization
  has_many :hosts
  has_and_belongs_to_many :operatingsystems
  before_destroy EnsureNotUsedBy.new(:hosts)
  validates_uniqueness_of :name
  validates_presence_of :layout
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain trailing white spaces."
  validates_inclusion_of :os_family, :in => Operatingsystem.families, :allow_nil => true
  default_scope :order => 'LOWER(ptables.name)'

  scoped_search :on => :name, :complete_value => true, :default_order => true
  scoped_search :on => :layout, :complete_value => false
  scoped_search :on => :os_family, :rename => "family", :complete_value => :true

  def as_json(options={})
    options ||= {}
    super({:only => [:name, :id]}.merge(options))
  end

  def os_family=(value)
    super(value.blank? ? nil : value)
  end

end
