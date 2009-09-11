class DomainParameter < Parameter
  belongs_to :domain
  validates_presence_of :domain_id
end
