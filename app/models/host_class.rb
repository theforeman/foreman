class HostClass < ApplicationRecord
  audited :associated_with => :host
  include Authorizable

  validates_lengths_from_database
  belongs_to_host
  belongs_to :puppetclass

  validates :puppetclass_id, :presence => true, :uniqueness => {:scope => :host_id}

  def name
    "#{host} - #{puppetclass}"
  end

  def check_permissions_after_save
    true
  end
end
