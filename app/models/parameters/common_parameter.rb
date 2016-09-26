class CommonParameter < Parameter
  audited :except => [:priority]
  validates :name, :uniqueness => true

  def associated_type
    N_('global')
  end
end
