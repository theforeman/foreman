class DomainParameter < Parameter
  belongs_to :domain, :foreign_key => :reference_id, :inverse_of => :domain_parameters
  audited :except => [:priority], :associated_with => :domain
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :domain, :presence => true

  def associated_type
    N_('domain')
  end

  def associated_label
    domain.to_label
  end
end
