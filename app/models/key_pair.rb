class KeyPair < ActiveRecord::Base
  belongs_to :compute_resource
  validates_presence_of :name, :secret, :compute_resource_id
  validates_uniqueness_of :compute_resource_id
end
