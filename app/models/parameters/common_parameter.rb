class CommonParameter < Parameter
  audited :except => [:priority], :allow_mass_assignment => true
  validates :name, :uniqueness => true

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :value, :complete_value => :true
end
