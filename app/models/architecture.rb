class Architecture < ActiveRecord::Base
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  validates_lengths_from_database

  has_many_hosts
  has_many :hostgroups
  has_many :images, :dependent => :destroy
  has_and_belongs_to_many :operatingsystems
  validates :name, :presence => true, :uniqueness => true,
                   :format => { :with => /\A(\S+)\Z/, :message => N_("can't contain white spaces.") }
  audited :allow_mass_assignment => true

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :hosts_count

end
