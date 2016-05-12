class HostParameter < Parameter
  belongs_to_host :foreign_key => :reference_id, :inverse_of => :host_parameters
  audited :except => [:priority], :associated_with => :host, :allow_mass_assignment => true
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :host, :presence => true

  def to_s
    "#{host.id ? host.name : 'unassociated'}: #{name} = #{value}"
  end

  def associated_type
    N_('host')
  end

  def associated_label
    host.to_label
  end
end
