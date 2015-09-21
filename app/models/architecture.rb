class Architecture < ActiveRecord::Base
  include Authorizable
  include Parameterizable::ByIdName

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  validates_lengths_from_database

  has_many_hosts
  has_many :hostgroups
  has_many :images, :dependent => :destroy
  has_and_belongs_to_many :operatingsystems
  validates :name, :presence => true, :uniqueness => true, :no_whitespace => true
  audited :allow_mass_assignment => true, :except => [:hosts_count, :hostgroups_count]

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :hosts_count
end
