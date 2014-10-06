object @role

attributes :name, :id, :builtin

node :permissions do |r|
  r.permissions.map(&:name)
end
