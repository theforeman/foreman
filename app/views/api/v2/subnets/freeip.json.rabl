object @ipam

node :freeip do |ipam|
  ipam.suggest_ip
end

node :errors do |ipam|
  ipam.errors.to_hash
end
