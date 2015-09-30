object @interface

attributes :id, :name, :ip, :mac, :identifier, :primary, :provision
node :type do |i|
  next if i.class == Symbol
  i.class.humanized_name.downcase
end
