class OrganizationUser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  validates_uniqueness_of :organization_id, :scope => :user_id
end
