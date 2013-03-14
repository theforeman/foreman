class Architecture < ActiveRecord::Base
  include Authorization

  has_many_hosts
  has_many :images, :dependent => :destroy
  has_and_belongs_to_many :operatingsystems
  validates_uniqueness_of :name
  before_destroy EnsureNotUsedBy.new(:hosts)
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => _("can't be blank or contain white spaces.")
  audited

  scoped_search :on => :name, :complete_value => :true

  def to_param
    name
  end

  def as_json(options={})
    options ||= {}
    super({:only => [:name, :id]}.merge(options))
  end

end
