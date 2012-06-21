class OrganizationDomain < ActiveRecord::Base
  belongs_to :organization
  belongs_to :domain

  validates_uniqueness_of :organization_id, :scope => :domain_id
end
