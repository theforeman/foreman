class OsParameter < Parameter
  belongs_to :operatingsystem, :foreign_key => :reference_id
  audited :except => [:priority], :associated_with => :operatingsystem, :allow_mass_assignment => true
  validates :name, :uniqueness => {:scope => :reference_id}

end
