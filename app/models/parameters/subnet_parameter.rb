class SubnetParameter < Parameter
  belongs_to :subnet, :foreign_key => :reference_id, :inverse_of => :subnet_parameters
  audited :except => [:priority], :associated_with => :subnet
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :subnet, :presence => true

  def associated_type
    N_('subnet')
  end

  def associated_label
    subnet.to_label
  end
end
