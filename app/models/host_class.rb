class HostClass < ActiveRecord::Base
  include Authorizable
  include CounterCacheFix

  validates_lengths_from_database
  audited :associated_with => :host, :allow_mass_assignment => true
  belongs_to_host :foreign_key => :host_id
  belongs_to :puppetclass, :counter_cache => :hosts_count

  validates :host_id, :presence => true
  validates :puppetclass_id, :presence => true, :uniqueness => {:scope => :host_id}

  def name
    "#{host} - #{puppetclass}"
  end

end
