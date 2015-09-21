class OsParameter < Parameter
  belongs_to :operatingsystem, :foreign_key => :reference_id, :inverse_of => :os_parameters
  audited :except => [:priority], :associated_with => :operatingsystem, :allow_mass_assignment => true
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :operatingsystem, :presence => true
end
