class GroupParameter < Parameter
  belongs_to :hostgroup
  validates_presence_of :hostgroup_id, :unless => :nested
  validates_uniqueness_of :name, :scope => :hostgroup_id
end
