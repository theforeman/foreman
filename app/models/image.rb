class Image < ActiveRecord::Base
  include Authorizable
  include SearchScope::Image

  audited :allow_mass_assignment => true

  belongs_to :operatingsystem
  belongs_to :compute_resource
  belongs_to :architecture

  has_many_hosts :dependent => :nullify

  validates_lengths_from_database
  validates :username, :name, :operatingsystem_id, :compute_resource_id, :architecture_id, :presence => true
  validates :uuid, :presence => true, :uniqueness => {:scope => :compute_resource_id}
end
