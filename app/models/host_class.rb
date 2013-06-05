class HostClass < ActiveRecord::Base
  include Authorization
  audited :associated_with => :host, :allow_mass_assignment => true
  belongs_to_host :foreign_key => :host_id
  belongs_to :puppetclass

  validates_presence_of :host_id, :puppetclass_id
  validates :puppetclass_id, :uniqueness => {:scope => :host_id}

  def name
    "#{host} - #{puppetclass}"
  end
end
