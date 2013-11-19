class Architecture < ActiveRecord::Base
  include Authorization

  before_destroy EnsureNotUsedBy.new(:systems, :system_groups)

  has_many_systems
  has_many :system_groups
  has_many :images, :dependent => :destroy
  has_and_belongs_to_many :operatingsystems
  validates :name, :uniqueness => true, :format => { :with => /\A(\S+)\Z/, :message => N_("can't be blank or contain white spaces.") }
  audited :allow_mass_assignment => true

  scoped_search :on => :name, :complete_value => :true

  def to_param
    "#{id}-#{name.parameterize}"
  end

end
