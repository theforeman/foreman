class KeyPair < ActiveRecord::Base
  belongs_to :compute_resource
  validates :name, :secret, :presence => true
  validates :compute_resource_id, :presence => true, :uniqueness => true
end
