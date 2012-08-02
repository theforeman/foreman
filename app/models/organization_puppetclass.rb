class OrganizationPuppetclass < ActiveRecord::Base
  belongs_to :organization
  belongs_to :puppetclass

  validates_uniqueness_of :organization_id, :scope => :puppetclass_id
end
