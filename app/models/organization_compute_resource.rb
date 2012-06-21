class OrganizationComputeResource < ActiveRecord::Base
  belongs_to :organization
  belongs_to :compute_resource

  validates_uniqueness_of :organization_id, :scope => :compute_resource_id
end
