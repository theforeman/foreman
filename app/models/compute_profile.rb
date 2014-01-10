class ComputeProfile < ActiveRecord::Base

  attr_accessible :name
  audited
  has_associated_audits

  before_destroy EnsureNotUsedBy.new(:hostgroups)
  has_many :compute_attributes
  has_many :compute_resources, :through => :compute_attributes
  has_many_hosts
  has_many :hostgroups

  validates :name, :presence => true, :uniqueness => true

  scoped_search :on => :name, :complete_value => true
  default_scope lambda { order('compute_profiles.name') }

  scope :visibles, lambda { includes(:compute_attributes).where('compute_attributes.id > 0') }

  def to_param
    "#{id}-#{name.parameterize}"
  end

end
