class HostClass < ActiveRecord::Base
  include Authorizable
  include AccessibleAttributes
  include PuppetclassTotalHosts::JoinTable

  validates_lengths_from_database
  audited :associated_with => :host, :allow_mass_assignment => true
  belongs_to_host
  belongs_to :puppetclass

# FIGURE OUT WHY FactoryGirl.create(:host, :with_puppetclass) DOESNT CREATE HOST_ID HERE
# validates :host_id, :presence => true
  validates :puppetclass_id, :presence => true, :uniqueness => {:scope => :host_id}

  def name
    "#{host} - #{puppetclass}"
  end
end
