class GroupParameter < Parameter
  belongs_to :hostgroup, :foreign_key => :reference_id, :inverse_of => :group_parameters
  audited :except => [:priority], :associated_with => :hostgroup
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :hostgroup, :presence => true

  def associated_type
    N_('host group')
  end

  def associated_label
    hostgroup.title
  end
end
