object @interface

attributes :id, :name, :ip, :ip6, :mac, :mtu, :fqdn, :identifier, :primary, :provision
node :type do |i|
  next if i.is_a? Symbol
  i.class.humanized_name.downcase
end
