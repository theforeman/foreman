object @usergroup

attributes :name, :id, :created_at, :updated_at

node do |ug|
  { :usergroup_members => ug.usergroup_member_ids }
end
