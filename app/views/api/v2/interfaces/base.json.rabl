object @interface

attributes :id, :name, :ip, :mac, :identifier, :primary, :provision
node :type do |i|
  i.class.humanized_name.downcase
end
