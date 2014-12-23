# This models the partition tables for a disk layouts
# It supports both static partition maps and dynamic scripts that create partition tables on-the-fly
# A host object may contain a reference to one of these ptables or, alternatively, it may contain a
# modified version of one of these in textual form
class Ptable < ActiveRecord::Base
  include Authorizable
  include SearchScope::PartitionTable
  extend FriendlyId
  friendly_id :name
  include ValidateOsFamily
  audited :allow_mass_assignment => true

  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  has_many_hosts
  has_many :hostgroups
  has_and_belongs_to_many :operatingsystems
  validates :layout, :presence => true
  validates :name, :presence => true, :uniqueness => true
  default_scope lambda { order('ptables.name') }
  validate_inclusion_in_families :os_family

  def skip_strip_attrs
    ['layout']
  end
end
