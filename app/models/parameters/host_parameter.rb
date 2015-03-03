class HostParameter < Parameter
  belongs_to_host :foreign_key => :reference_id, :inverse_of => :host_parameters
  audited :except => [:priority], :associated_with => :host, :allow_mass_assignment => true
  validates :name, :uniqueness => {:scope => :reference_id}

  def to_s
    "#{host ? host.name : "unassociated"}: #{name} = #{value}"
  end
end
