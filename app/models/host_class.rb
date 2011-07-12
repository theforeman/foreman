class HostClass < ActiveRecord::Base
  acts_as_audited :parent => :host
  belongs_to :host
  belongs_to :puppetclass

  validates_presence_of :host_id, :puppetclass_id

  def name
    "#{host} - #{puppetclass}"
  end
end
