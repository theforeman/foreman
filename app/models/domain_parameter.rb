class DomainParameter < Parameter
  belongs_to :domain
  validates_presence_of :domain_id, :message => "parameters require an associated domain", :unless => :nested
  validates_uniqueness_of :name
end
