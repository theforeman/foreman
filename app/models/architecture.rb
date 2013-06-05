class Architecture < ActiveRecord::Base
  include Authorization

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)

  has_many_hosts
  has_many :hostgroups
  has_many :images, :dependent => :destroy
  has_and_belongs_to_many :operatingsystems
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => N_("can't be blank or contain white spaces.")
  audited :allow_mass_assignment => true

  scoped_search :on => :name, :complete_value => :true

  def to_param
    name
  end

  def as_json(options={})
    options ||= {}
    super({:only => [:name, :id]}.merge(options))
  end

end
