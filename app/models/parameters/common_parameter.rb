class CommonParameter < Parameter
  include SearchScope::CommonParameter
  audited :except => [:priority], :allow_mass_assignment => true
  validates :name, :uniqueness => true
end
