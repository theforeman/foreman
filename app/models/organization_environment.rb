class OrganizationEnvironment < ActiveRecord::Base
  belongs_to :organization
  belongs_to :environment

  validates_uniqueness_of :organization_id, :scope => :environment_id
end
