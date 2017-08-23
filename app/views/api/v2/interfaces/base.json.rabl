object @interface

attributes :id, :name, :ip, :ip6, :mac, :identifier, :primary, :provision, :execution
node :type do |i|
  next if i.is_a? Symbol
  i.class.humanized_name.downcase
end
