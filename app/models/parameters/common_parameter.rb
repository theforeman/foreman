class CommonParameter < Parameter
  audited :except => [:priority]
  validates :name, :uniqueness => true

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :value, :complete_value => :true

  def associated_type
    N_('global')
  end
end
