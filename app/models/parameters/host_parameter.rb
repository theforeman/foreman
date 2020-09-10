class HostParameter < Parameter
  audited :except => [:priority, :searchable_value], :associated_with => :host
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
