class DomainParameter < Parameter
  belongs_to :domain, :foreign_key => :reference_id
  audited :except => [:priority], :associated_with => :domain, :allow_mass_assignment => true
  validates :name, :uniqueness => {:scope => :reference_id}
end
