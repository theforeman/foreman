object @ipam

node :freeip do |ipam|
  ipam.present? ? ipam.suggest_ip : nil
end
