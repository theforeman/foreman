class SubnetComputeResource < ActiveRecord::Base
  belongs_to :subnet
  belongs_to :compute_resource

  validates :subnet, :presence => true
  validates :compute_resource, :presence => true

  def to_s
    "#{compute_resource} : #{subnet}"
  end
end
