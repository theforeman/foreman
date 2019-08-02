class GroupParameter < Parameter
  audited :except => [:priority, :searchable_value], :associated_with => :hostgroup
  validates :name, :uniqueness => {:scope => :reference_id}
  validates :hostgroup, :presence => true

  def associated_type
    N_('host group')
  end

  def associated_label
    hostgroup.title
  end
end
