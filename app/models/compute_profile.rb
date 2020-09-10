class ComputeProfile < ApplicationRecord
  audited
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  validates_lengths_from_database

  has_associated_audits

  before_destroy EnsureNotUsedBy.new(:hostgroups)
  has_many :compute_attributes, :dependent => :destroy
  has_many :compute_resources, :through => :compute_attributes
  has_many_hosts :dependent => :nullify
  has_many :hostgroups

  validates :name, :presence => true, :uniqueness => true

  scoped_search :on => :name, :complete_value => true
  default_scope -> { order('compute_profiles.name') }

  scope :visibles, -> { where(:id => ComputeAttribute.select(:compute_profile_id)) }
end
