class KeyPair < ActiveRecord::Base
  belongs_to :compute_resource
  validates_lengths_from_database
  validates :name, :secret, :presence => true
  validates :compute_resource_id, :presence => true, :uniqueness => true
  audited :except => :secret, :associated_with => :compute_resource

  def skip_strip_attrs
    ['secret']
  end
end
