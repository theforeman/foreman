class HostClass < ActiveRecord::Base
  include Authorizable

  validates_lengths_from_database
  audited :associated_with => :host
  belongs_to_host_managed
  belongs_to :puppetclass

  validates :puppetclass_id, :presence => true, :uniqueness => {:scope => :host_id}

  def name
    "#{host} - #{puppetclass}"
  end
end
