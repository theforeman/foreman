class DomainParameter < Parameter
  belongs_to :domain, :foreign_key => :reference_id, :inverse_of => :domain_parameters
  audited :except => [:priority], :associated_with => :domain, :allow_mass_assignment => true
end
