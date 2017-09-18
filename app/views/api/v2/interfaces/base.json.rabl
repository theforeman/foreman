object @interface

attributes :id, :name, :ip, :ip6, :mac, :fqdn, :identifier, :managed, :primary, :provision, :virtual, :created_at, :updated_at, :domain_id, :domain_name, :subnet_id, :subnet_name
node :type do |i|
  next if i.is_a? Symbol
  i.class.humanized_name.downcase
end
