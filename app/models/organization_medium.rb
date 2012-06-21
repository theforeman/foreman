class OrganizationMedium < ActiveRecord::Base
  belongs_to :organization
  belongs_to :medium

  validates_uniqueness_of :organization_id, :scope => :medium_id
end
