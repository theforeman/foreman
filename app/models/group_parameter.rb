class GroupParameter < Parameter
  belongs_to :hostgroup
  validates_presence_of :hostgroup_id
end
