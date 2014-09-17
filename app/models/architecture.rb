class Architecture < ActiveRecord::Base
  include Authorizable

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  validates_lengths_from_database

  has_many_hosts
  has_many :hostgroups
  has_many :images, :dependent => :destroy
  has_many :architecture_operatingsystems, :dependent => :destroy
  has_many :operatingsystems, :through => :architecture_operatingsystems
  validates :name, :presence => true, :uniqueness => true,
                   :format => { :with => /\A(\S+)\Z/, :message => N_("can't contain white spaces.") }
  audited :allow_mass_assignment => true

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :hosts_count

  def to_param
    "#{id}-#{name.parameterize}"
  end

end
