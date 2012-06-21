class OrganizationHostgroup < ActiveRecord::Base
  belongs_to :organization
  belongs_to :hostgroup

  validates_uniqueness_of :organization_id, :scope => :hostgroup_id
end
