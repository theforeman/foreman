class DomainParameter < Parameter
  audited :except => [:priority, :searchable_value], :associated_with => :domain
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :domain, :presence => true

  def associated_type
    N_('domain')
  end

  def associated_label
    domain.to_label
  end
end
