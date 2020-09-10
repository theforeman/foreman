class CommonParameter < Parameter
  audited :except => [:priority, :searchable_value]
  validates :name, :uniqueness => true

  def associated_type
    N_('global')
  end
end
