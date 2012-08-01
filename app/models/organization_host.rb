class OrganizationHost < ActiveRecord::Base
  belongs_to :organization
  belongs_to :host

  validates_uniqueness_of :organization_id, :scope => :host_id
end
