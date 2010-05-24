class GroupParameter < Parameter
  belongs_to :hostgroup, :foreign_key => :reference_id
  validates_uniqueness_of :name, :scope => :reference_id
end
