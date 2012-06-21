class OrganizationSmartProxy < ActiveRecord::Base
  belongs_to :organization
  belongs_to :smart_proxy

  validates_uniqueness_of :organization_id, :scope => :smart_proxy_id
end
