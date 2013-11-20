class Architecture < ActiveRecord::Base
  include Authorizable

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)

  has_many_hosts
  has_many :hostgroups
  has_many :images, :dependent => :destroy
  has_and_belongs_to_many :operatingsystems
  validates :name, :uniqueness => true, :format => { :with => /\A(\S+)\Z/, :message => N_("can't be blank or contain white spaces.") }
  audited :allow_mass_assignment => true

  scoped_search :on => :name, :complete_value => :true

  def to_param
    "#{id}-#{name.parameterize}"
  end

end
