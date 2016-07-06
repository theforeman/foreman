class OsParameter < Parameter
  belongs_to :operatingsystem, :foreign_key => :reference_id, :inverse_of => :os_parameters
  audited :except => [:priority], :associated_with => :operatingsystem
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :operatingsystem, :presence => true

  def associated_type
    N_('operating system')
  end

  def associated_label
    operatingsystem.to_label
  end
end
