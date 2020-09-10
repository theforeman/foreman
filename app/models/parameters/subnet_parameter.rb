class SubnetParameter < Parameter
  audited :except => [:priority, :searchable_value], :associated_with => :subnet
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :subnet, :presence => true

  def associated_type
    N_('subnet')
  end

  def associated_label
    subnet.to_label
  end
end
