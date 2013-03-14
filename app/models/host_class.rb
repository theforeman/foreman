class HostClass < ActiveRecord::Base
  audited :associated_with => :host
  belongs_to :host, :foreign_key => :host_id
  belongs_to :puppetclass

  validates_presence_of :host_id, :puppetclass_id
  validates :puppetclass_id, :uniqueness => {:scope => :host_id}

  def name
    "#{host} - #{puppetclass}"
  end
end
