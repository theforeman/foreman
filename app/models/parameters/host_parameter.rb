class HostParameter < Parameter
  belongs_to_host :foreign_key => :reference_id
  audited :except => [:priority], :associated_with => :host, :allow_mass_assignment => true
  validates :name, :uniqueness => {:scope => :reference_id}

  def to_s
    "#{host.id ? host.name : "unassociated"}: #{name} = #{value}"
  end

end
