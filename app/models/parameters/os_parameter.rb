class OsParameter < Parameter
  audited :except => [:priority, :searchable_value], :associated_with => :operatingsystem
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :operatingsystem, :presence => true

  def associated_type
    N_('operating system')
  end

  def associated_label
    operatingsystem.to_label
  end
end
